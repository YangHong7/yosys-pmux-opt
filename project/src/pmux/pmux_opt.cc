/*
代码结构：基于pass框架
优化目标：针对pmux有关典型结构的优化
设计队伍：玛莎的苹果汁好喝对不队
设计与优化时间：26/9/20-26/10/31
 */

#include "kernel/yosys.h"
#include "kernel/sigtools.h"
#include "kernel/celltypes.h"
#include <algorithm>
#include <cstdint>
#include <functional>
#include <map>
#include <set>
#include <tuple>

USING_YOSYS_NAMESPACE
PRIVATE_NAMESPACE_BEGIN

// P5实现
struct PmuxCompleteDecoderRegion
{
    struct Dec {SigSpec a;int v;};
    struct Choice {Cell *c;SigSpec address;std::vector<SigSpec> leaves;std::vector<SigBit> cond;int missing,width;};
    struct BNode {char op;int x=0,y=0,value=0;SigBit bit;SigSpec address;};
    struct BoolPlan {
        std::vector<BNode> nodes=std::vector<BNode>(2);
        dict<SigBit,int> inputs;
        std::map<std::tuple<char,int,int>,int> cache;
        std::map<std::pair<SigSpec,int>,int> eqs;
        int literal(SigBit b) {if(!b.wire)return b==State::S1?1:0;auto i=inputs.find(b);if(i!=inputs.end())return i->second;int id=nodes.size();BNode n;n.op='I';n.bit=b;nodes.push_back(n);inputs[b]=id;return id;}
        int eq(SigSpec a,int v) {auto key=std::make_pair(a,v);auto i=eqs.find(key);if(i!=eqs.end())return i->second;int id=nodes.size();BNode n;n.op='E';n.address=a;n.value=v;nodes.push_back(n);eqs[key]=id;return id;}
        int combine(char op,int a,int b) {
            if(a==b)return a;
            if(op=='&'){if(!a||!b)return 0;if(a==1)return b;if(b==1)return a;}
            else {if(a==1||b==1)return 1;if(!a)return b;if(!b)return a;}
            if(a>b) { std::swap(a,b); }
            auto key=std::make_tuple(op,a,b);auto it=cache.find(key);if(it!=cache.end())return it->second;
            int id=nodes.size();BNode n;n.op=op;n.x=a;n.y=b;nodes.push_back(n);cache[key]=id;return id;
        }
        int gates()const{int n=0;for(size_t i=2;i<nodes.size();i++)if(nodes[i].op!='I')n++;return n;}
        std::vector<SigBit> emit(Module *m,std::string src) {
            std::vector<SigBit> out(nodes.size());out[0]=State::S0;out[1]=State::S1;
            for(size_t i=2;i<nodes.size();i++) {auto &n=nodes[i];if(n.op=='I'){out[i]=n.bit;continue;}Wire *y=m->addWire(NEW_ID,1);out[i]=SigBit(y);
                if(n.op=='E')m->addEq(NEW_ID,n.address,Const(n.value,GetSize(n.address)),y,false,src);
                else if(n.op=='&')m->addAnd(NEW_ID,out[n.x],out[n.y],y,false,src);
                else m->addOr(NEW_ID,out[n.x],out[n.y],y,false,src);
            }return out;
        }
    };
    static int run(Design *design, bool verbose) {
        const bool dag = true, force = false, reverse = false;
        int ntree=0,ndag=0,skipped=0;
        for(auto m:design->selected_modules()) {
            SigMap sm(m);dict<SigBit,Dec> dec;pool<SigBit> ambiguous;
            for(auto c:m->cells()) {
                if(c->type!=ID($eq)&&c->type!=ID($logic_not))continue;
                SigSpec a=sm(c->getPort(ID::A));int v=0;
                if(c->type==ID($eq)){SigSpec b=sm(c->getPort(ID::B));if(a.is_fully_const())std::swap(a,b);if(!b.is_fully_def()||GetSize(b)>32)continue;
                    if((c->hasParam(ID::A_SIGNED)&&c->getParam(ID::A_SIGNED).as_bool())||(c->hasParam(ID::B_SIGNED)&&c->getParam(ID::B_SIGNED).as_bool())) { continue; }
                    v=b.as_const().as_int();}
                int n=GetSize(a);if(n<2||n>3||a.has_const()||GetSize(a.to_sigbit_pool())!=n||v<0||v>=(1<<n))continue;
                SigSpec y=sm(c->getPort(ID::Y));if(GetSize(y)!=1||!y[0].wire)continue;if(dec.count(y[0])){ambiguous.insert(y[0]);continue;}dec.emplace(y[0],Dec{a,v});
            }
            
            dict<Cell*,Choice> choices;std::vector<Cell*> ordered;
            for(auto c:m->selected_cells()) {
                if(c->type!=ID($pmux)) { continue; }
                int w=c->getParam(ID::WIDTH).as_int();SigSpec s=sm(c->getPort(ID::S));int n=GetSize(s);if(w<1||(n!=3&&n!=7))continue;
                Choice q;q.c=c;q.width=w;q.missing=-1;q.leaves.resize(n+1,c->getPort(ID::A));q.cond.resize(n+1,State::Sx);std::set<int> used;bool ok=true;int lane=0;
                for(auto bit:s){auto it=dec.find(bit);if(it==dec.end()||ambiguous.count(bit)){ok=false;break;}auto &d=it->second;if(GetSize(q.address)==0)q.address=d.a;if(q.address!=d.a||!used.insert(d.v).second){ok=false;break;}q.leaves[d.v]=c->getPort(ID::B).extract(lane*w,w);q.cond[d.v]=bit;lane++;}
                if(!ok||(1<<GetSize(q.address))!=n+1) { continue; }
                for(int v=0;v<=n;v++)if(!used.count(v))q.missing=v;
                choices.emplace(c,q);ordered.push_back(c);
            }
            dict<SigSpec,Cell*> byoutput;dict<SigBit,Cell*> driver;dict<Cell*,pool<Cell*>> users;dict<Cell*,pool<Cell*>> parents;
            
            dict<Cell*,Cell*> uf;
            for(auto c:m->cells())if(c->type==ID($pmux)){uf[c]=c;for(auto b:sm(c->getPort(ID::Y)))if(b.wire)driver[b]=c;if(choices.count(c))byoutput[sm(c->getPort(ID::Y))]=c;}
            std::function<Cell*(Cell*)> find=[&](Cell*c)->Cell*{if(uf.at(c)!=c)uf[c]=find(uf.at(c));return uf.at(c);};
            for(auto c:m->cells())for(auto &port:c->connections())if(c->input(port.first))for(auto b:sm(port.second)){
                auto d=driver.find(b);if(d==driver.end())continue;users[d->second].insert(c);if(c->type==ID($pmux))uf[find(c)]=find(d->second);
            }
            for(auto w:m->wires())if(w->port_output)for(auto b:sm(w)){auto d=driver.find(b);if(d!=driver.end())users[d->second].insert(nullptr);}
            pool<Cell*> bad;
            for(auto &entry:uf)if(GetSize(users[entry.first])>1)bad.insert(find(entry.first));
            for(auto c:ordered)for(auto &leaf:choices.at(c).leaves){auto d=byoutput.find(sm(leaf));if(d!=byoutput.end()&&choices.at(d->second).width==choices.at(c).width)parents[d->second].insert(c);}
            pool<Cell*> consumed;std::vector<Cell*> remove_later;
            
            if(dag)for(auto root:ordered) {
                if(!parents[root].empty()||!bad.count(find(root)))continue;
                pool<Cell*> cone,visiting;std::vector<Cell*> post;bool ok=true;dict<Cell*,int> incoming;
                std::function<void(Cell*,int)> visit=[&](Cell*c,int depth){if(depth>8||GetSize(cone)>=16){ok=false;return;}if(visiting.count(c)){ok=false;return;}if(cone.count(c))return;cone.insert(c);visiting.insert(c);
                    for(auto &leaf:choices.at(c).leaves){auto d=byoutput.find(sm(leaf));if(d!=byoutput.end()&&choices.at(d->second).width==choices.at(root).width){incoming[d->second]++;visit(d->second,depth+1);}}
                    visiting.erase(c);post.push_back(c);
                };visit(root,0);if(!ok)continue;
                
                bool shared=false;for(auto c:cone){if(incoming[c]>1)shared=true;if(c!=root)for(auto u:users[c])if(!u||!cone.count(u))ok=false;}
                if(!ok||!shared)continue;
                BoolPlan plan;dict<Cell*,int> en;en[root]=1;dict<SigSpec,int> terms;std::vector<SigSpec> leaforder;
                for(auto it=post.rbegin();it!=post.rend();it++) {auto c=*it;auto &q=choices.at(c);for(int v=0;v<GetSize(q.leaves);v++) {
                    int local=v==q.missing?plan.eq(q.address,v):plan.literal(q.cond[v]);int active=plan.combine('&',en[c],local);SigSpec data=sm(q.leaves[v]);auto d=byoutput.find(data);
                    if(d!=byoutput.end()&&cone.count(d->second))en[d->second]=plan.combine('|',en[d->second],active);
                    else {if(!terms.count(data))leaforder.push_back(data);terms[data]=plan.combine('|',terms[data],active);}
                }}
                int width=choices.at(root).width,n=GetSize(leaforder);int treecost=0;for(auto c:cone)treecost+=GetSize(choices.at(c).leaves)-1;
                
                int flatcost=((n+1)/2+(n<=4?0:n<=8?1:2))*width+plan.gates();
                if(n<2||n>24||(!force&&flatcost>=treecost*width)){skipped++;continue;}
                
                std::string src=root->get_src_attribute();SigSpec root_y=root->getPort(ID::Y);auto enabled=plan.emit(m,src);SigSpec data,select;
                
                for(auto &leaf:leaforder){data.append(leaf);select.append(enabled[terms.at(leaf)]);}
                
                Wire*y=m->addWire(NEW_ID,width);m->addPmux(NEW_ID,Const(State::S0,width),data,select,y,src);m->connect(root_y,y);
                
                for(auto c:cone) { consumed.insert(c); }
                remove_later.push_back(root);ndag++;
                if (verbose) log("P5 region DAG nodes=%d leaves=%d control=%d estimate=%d->%d.\n",GetSize(cone),n,plan.gates(),treecost*width,flatcost);
            }
            for(auto c:ordered){if(consumed.count(c)||bad.count(find(c)))continue;auto&q=choices.at(c);std::vector<int> order;for(int b=0;b<GetSize(q.address);b++)order.push_back(b);if(reverse)std::reverse(order.begin(),order.end());
                std::function<SigSpec(int,int)> emit=[&](int level,int code)->SigSpec{if(level==GetSize(order))return q.leaves[code];int b=order[level];SigSpec lo=emit(level+1,code),hi=emit(level+1,code|(1<<b));if(sm(lo)==sm(hi))return lo;Wire*y=m->addWire(NEW_ID,q.width);m->addMux(NEW_ID,lo,hi,q.address[b],y,c->get_src_attribute());return y;};
                SigSpec y=emit(0,0);m->connect(c->getPort(ID::Y),y);remove_later.push_back(c);ntree++;
            }

            for(auto c:remove_later)m->remove(c);
        }
        log("  P5 complete-decoder regions: trees=%d dags=%d budget_reject=%d.\n",ntree,ndag,skipped);
        return ntree + ndag;
    }
};

struct PmuxOptPass : public Pass
{
	PmuxOptPass() : Pass("pmux_opt", "run selectable PMUX optimization rules") { }

	void help() override
	{
		log("\n");
		log("    pmux_opt [options] [selection]\n");
		log("\n");
		log("Run selectable structural optimization rules. With no rule\n");
		log("option, all five rules (P1-P5) run. If one or more rule\n");
		log("options are given, only the named rules are enabled.\n");
		log("\n");
		log("    -p1, -group\n");
		log("        rule P1 (test1): paired-PMUX swap factoring\n");
		log("\n");
		log("    -p2\n");
		log("        rule P2 (test2): balance a four-level priority mux chain\n");
		log("\n");
		log("    -p3\n");
		log("        plan shared partial constant comparisons for 4-LUT mapping\n");
		log("\n");
		log("    -p4\n");
		log("        decompose fully defined asynchronous ROMs with 1..5 address bits\n");
		log("        and up to 64 output bits; share reduced/complementary cofactors\n");
		log("\n");
		log("    -p5\n");
		log("        normalize bounded complete-decoder PMUX trees and shared regions\n");
		log("\n");
		log("    -all\n");
		log("        explicitly enable all five rules (P1-P5)\n");
		log("\n");
		log("    -v, -verbose\n");
		log("        print rule matching details\n");
		log("\n");
		log("Examples:\n");
		log("    pmux_opt                 # P1-P5 (default)\n");
		log("    pmux_opt -p1             # P1 only\n");
		log("    pmux_opt -all            # P1-P5\n");
		log("    pmux_opt -p1 top/*       # P1 on the selection\n");
		log("\n");
	}

	static int run_group_rule(RTLIL::Design *design, bool verbose)
	{
		int changes = 0;

		for (auto module : design->selected_modules()) {
			SigMap sigmap(module);
			std::vector<RTLIL::Cell *> pmuxes;
			for (auto cell : module->selected_cells())
				if (cell->type == ID($pmux))
					pmuxes.push_back(cell);
			pool<RTLIL::Cell *> used;

			for (int first = 0; first < GetSize(pmuxes); first++) {
				RTLIL::Cell *cell_a = pmuxes[first];
				if (used.count(cell_a))
					continue;
				int width = cell_a->getParam(ID::WIDTH).as_int();
				int s_width = cell_a->getParam(ID::S_WIDTH).as_int();
				if (width <= 0 || s_width < 6 || (s_width & 1))
					continue;

				RTLIL::Cell *best_b = nullptr;
				std::vector<int> best_pairs;
				RTLIL::SigSpec a_s = sigmap(cell_a->getPort(ID::S));
				RTLIL::SigSpec a_b = cell_a->getPort(ID::B);

				for (int second = first + 1; second < GetSize(pmuxes); second++) {
					RTLIL::Cell *cell_b = pmuxes[second];
					if (used.count(cell_b) || cell_b->getParam(ID::WIDTH).as_int() != width ||
						cell_b->getParam(ID::S_WIDTH).as_int() != s_width ||
						sigmap(cell_b->getPort(ID::S)) != a_s)
						continue;

					RTLIL::SigSpec b_b = cell_b->getPort(ID::B);
					std::vector<int> pairs;
					for (int lane = 0; lane + 1 < s_width; lane += 2) {
						RTLIL::SigSpec a0 = sigmap(a_b.extract(lane * width, width));
						RTLIL::SigSpec a1 = sigmap(a_b.extract((lane + 1) * width, width));
						RTLIL::SigSpec b0 = sigmap(b_b.extract(lane * width, width));
						RTLIL::SigSpec b1 = sigmap(b_b.extract((lane + 1) * width, width));
						if (a0 == b1 && a1 == b0 && a0 != a1)
							pairs.push_back(lane);
					}
					if (GetSize(pairs) > GetSize(best_pairs)) {
						best_b = cell_b;
						best_pairs.swap(pairs);
					}
				}

				if (best_b == nullptr || GetSize(best_pairs) < 3)
					continue;


                auto independent_data_cones = [&]() {
                    CellTypes ct(design);
                    pool<RTLIL::SigBit> roots, visited;
                    for (auto c : {cell_a, best_b})
                        for (auto bit : sigmap(c->getPort(ID::Y)))
                            roots.insert(bit);
                    dict<RTLIL::SigBit, pool<RTLIL::Cell *>> drivers;
                    for (auto c : module->cells())
                        for (auto &port : c->connections())
                            if (!ct.cell_known(c->type) || ct.cell_output(c->type, port.first))
                                for (auto bit : sigmap(port.second))
                                    if (bit.wire != nullptr)
                                        drivers[bit].insert(c);
                    std::vector<RTLIL::SigBit> pending;
                    for (auto c : {cell_a, best_b})
                        for (auto p : {ID::A, ID::B, ID::S})
                            for (auto bit : sigmap(c->getPort(p)))
                                pending.push_back(bit);
                    while (!pending.empty()) {
                        auto bit = pending.back();
                        pending.pop_back();
                        if (roots.count(bit))
                            return false;
                        if (bit.wire == nullptr || !visited.insert(bit).second)
                            continue;
                        auto it = drivers.find(bit);
                        if (it == drivers.end())
                            continue;
                        for (auto c : it->second) {
                            if (RTLIL::builtin_ff_cell_types().count(c->type))
                                continue;

                            if (!ct.cell_known(c->type) || !ct.cell_evaluable(c->type))
                                return false;
                            for (auto &port : c->connections())
                                if (ct.cell_input(c->type, port.first))
                                    for (auto inbit : sigmap(port.second))
                                        pending.push_back(inbit);
                        }
                    }
                    return true;
                };
                std::vector<int> group_pairs = best_pairs;
                if (GetSize(best_pairs) < s_width / 2 && independent_data_cones()) {
                    group_pairs.clear();
                    for (int lane = 0; lane + 1 < s_width; lane += 2)
                        group_pairs.push_back(lane);
                }

				RTLIL::SigSpec raw_s = cell_a->getPort(ID::S);
				RTLIL::SigSpec b_b = best_b->getPort(ID::B);
				RTLIL::SigSpec group_s, combined_b, swap_s;
				std::vector<bool> matched(s_width, false);
				std::string src = cell_a->get_src_attribute();

				//一对内两个状态的数据不同时，在共享结构内部用 2 选 1 区分（部分交换）
				auto pick = [&](const RTLIL::SigSpec &stay, const RTLIL::SigSpec &swap, RTLIL::SigBit sel) -> RTLIL::SigSpec {
					if (sigmap(stay) == sigmap(swap))
						return stay;
					RTLIL::Wire *y = module->addWire(NEW_ID, width);
					module->addMux(NEW_ID, stay, swap, sel, y, src);
					return y;
				};

				int partial = 0;
				for (int lane : group_pairs) {
					matched[lane] = matched[lane + 1] = true;
					RTLIL::Wire *group_bit = module->addWire(NEW_ID, 1);
					module->addOr(NEW_ID, raw_s[lane], raw_s[lane + 1], group_bit, false, src);
					group_s.append(group_bit);
					swap_s.append(raw_s[lane + 1]);

					RTLIL::SigSpec a0 = a_b.extract(lane * width, width), a1 = a_b.extract((lane + 1) * width, width);
					RTLIL::SigSpec b0 = b_b.extract(lane * width, width), b1 = b_b.extract((lane + 1) * width, width);
					if (sigmap(a0) != sigmap(b1) || sigmap(b0) != sigmap(a1))
						partial++;
					combined_b.append(pick(a0, b1, raw_s[lane + 1]));
					combined_b.append(pick(b0, a1, raw_s[lane + 1]));
				}

				RTLIL::Wire *pair_raw = module->addWire(NEW_ID, 2 * width);
				module->addPmux(NEW_ID, RTLIL::Const(RTLIL::State::Sx, 2 * width), combined_b, group_s, pair_raw, src);
				RTLIL::Wire *swap_active = module->addWire(NEW_ID, 1);
				module->addReduceOr(NEW_ID, swap_s, swap_active, false, src);

				RTLIL::SigSpec swapped;
				swapped.append(RTLIL::SigSpec(pair_raw).extract(width, width));
				swapped.append(RTLIL::SigSpec(pair_raw).extract(0, width));
				RTLIL::Wire *pair_final = module->addWire(NEW_ID, 2 * width);
				module->addMux(NEW_ID, pair_raw, swapped, swap_active, pair_final, src);

				RTLIL::Wire *group_active = module->addWire(NEW_ID, 1);
				module->addReduceOr(NEW_ID, group_s, group_active, false, src);

				auto rebuild_pmux = [&](RTLIL::Cell *cell, const RTLIL::SigSpec &pair_data) {
					RTLIL::SigSpec old_b = cell->getPort(ID::B);
					RTLIL::SigSpec old_s = cell->getPort(ID::S);
					RTLIL::SigSpec new_b, new_s;
					for (int lane = 0; lane < s_width; lane++)
						if (!matched[lane]) {
							new_b.append(old_b.extract(lane * width, width));
							new_s.append(old_s[lane]);
						}
					new_b.append(pair_data);
					new_s.append(group_active);
					cell->setPort(ID::B, new_b);
					cell->setPort(ID::S, new_s);
					cell->setParam(ID::S_WIDTH, GetSize(new_s));
				};

				rebuild_pmux(cell_a, RTLIL::SigSpec(pair_final).extract(0, width));
				rebuild_pmux(best_b, RTLIL::SigSpec(pair_final).extract(width, width));
				used.insert(cell_a);
				used.insert(best_b);
				changes++;

				if (verbose)
					log("  P1 %s: paired %s and %s, factored %d lane pair(s) (%d swapped, %d partial).\n",
						log_id(module), log_id(cell_a), log_id(best_b), GetSize(group_pairs), GetSize(best_pairs), partial);
			}
		}

		return changes;
	}

	static int run_priority_balance_rule(RTLIL::Design *design, bool verbose)
	{
		int changes = 0;

		for (auto module : design->selected_modules()) {
			SigMap sigmap(module);
			dict<RTLIL::SigBit, RTLIL::Cell *> mux_drivers;
			std::vector<RTLIL::Cell *> muxes;

			//建立信号位到mux驱动的索引
			for (auto cell : module->cells()) {
				if (cell->type != ID($mux))
					continue;
				muxes.push_back(cell);
				for (auto bit : sigmap(cell->getPort(ID::Y)))
					mux_drivers[bit] = cell;
			}

			//局部函数，反向查找；可以访问外围局部变量
			pool<RTLIL::Cell *> rewritten;
			auto driving_mux = [&](const RTLIL::SigSpec &signal) -> RTLIL::Cell * {
				RTLIL::SigSpec mapped = sigmap(signal);
				if (GetSize(mapped) == 0)
					return nullptr;
				auto it = mux_drivers.find(mapped[0]);
				if (it == mux_drivers.end())
					return nullptr;
				RTLIL::Cell *driver = it->second;
				if (rewritten.count(driver))
					return nullptr;
				return sigmap(driver->getPort(ID::Y)) == mapped ? driver : nullptr;
			};

			//主操作
			for (auto top : muxes) {
				if (rewritten.count(top) || !design->selected(module, top))
					continue;

				int width = top->getParam(ID::WIDTH).as_int();
				if (width <= 1 || GetSize(top->getPort(ID::S)) != 1)
					continue;


				//查找符合条件的四级mux链
				RTLIL::Cell *second = driving_mux(top->getPort(ID::A));
				if (second == nullptr || second == top || second->type != ID($mux) ||
					second->getParam(ID::WIDTH).as_int() != width || GetSize(second->getPort(ID::S)) != 1)
					continue;
				RTLIL::Cell *third = driving_mux(second->getPort(ID::A));
				if (third == nullptr || third->type != ID($mux) ||
					third->getParam(ID::WIDTH).as_int() != width || GetSize(third->getPort(ID::S)) != 1)
					continue;
				RTLIL::Cell *fourth = driving_mux(third->getPort(ID::A));
				if (fourth == nullptr || fourth->type != ID($mux) ||
					fourth->getParam(ID::WIDTH).as_int() != width || GetSize(fourth->getPort(ID::S)) != 1)
					continue;

				//重组
				RTLIL::SigSpec first_sel = top->getPort(ID::S);
				RTLIL::SigSpec second_sel = second->getPort(ID::S);
				std::string src = top->get_src_attribute();

				RTLIL::Wire *left = module->addWire(NEW_ID, width);
				module->addMux(NEW_ID, second->getPort(ID::B), top->getPort(ID::B), first_sel, left, src);
				RTLIL::Wire *left_active = module->addWire(NEW_ID, 1);
				module->addOr(NEW_ID, first_sel, second_sel, left_active, false, src);
				module->addMux(NEW_ID, third->getPort(ID::Y), left, left_active, top->getPort(ID::Y), src);

				if (verbose)
					log("  P2 %s.%s: balanced four-level priority mux, width %d.\n",
						log_id(module), log_id(top), width);
				module->remove(top);
				rewritten.insert(top);
				changes++;
			}
		}

		return changes;
	}

	//P3选择位共享
	struct ComparePlanner {
	    using Mask=uint64_t;
	    struct Pred { Mask mask,value; bool operator<(const Pred &b) const {return std::tie(mask,value)<std::tie(b.mask,b.value);} };
	    struct Entry { Cell *cell; SigSpec y; Mask value; int capacity; std::string src; };
	    struct Term { Pred p; int node,depth; };
	    struct Node { Pred p; std::vector<Term> inputs; int depth; };
	    struct Graph {
	        std::vector<Node> nodes;
	        std::map<Pred,int> cache;
	        std::vector<Term> roots;
	        int maxdepth=0,depthsum=0;
	        Term raw(int bit,bool val) {Mask m=Mask(1)<<bit;return {{m,val?m:0},-1,0};}
	        Term join(const std::vector<Term> &terms) {
	            if (terms.size()==1) return terms.front();
	            log_assert(terms.size()>=2 && terms.size()<=4);
	            Pred p{0,0};int depth=0;
	            for (auto &t:terms) {log_assert(!(p.mask&t.p.mask));p.mask|=t.p.mask;p.value|=t.p.value;depth=std::max(depth,t.depth);}
	            auto it=cache.find(p);
	            if (it!=cache.end()) {auto &n=nodes[it->second];return {p,it->second,n.depth};}
	            int idx=nodes.size();nodes.push_back({p,terms,depth+1});cache[p]=idx;return {p,idx,depth+1};
	        }
	        Term reduce(std::vector<Term> terms,int rootcap) {
	            log_assert(!terms.empty());
	            while (GetSize(terms)>rootcap) {
	                std::stable_sort(terms.begin(),terms.end(),[](const Term &a,const Term &b){return std::tie(a.depth,a.p.mask,a.p.value)<std::tie(b.depth,b.p.mask,b.p.value);});
	                int k=std::min(4,GetSize(terms)-rootcap+1);
	                log_assert(k>=2);
	                std::vector<Term> part(terms.begin(),terms.begin()+k);
	                Term t=join(part);terms.erase(terms.begin(),terms.begin()+k);terms.push_back(t);
	            }
	            return join(terms);
	        }
	        Term compare(Pred p,int width) {
	            auto hit=cache.find(p);
	            if (hit!=cache.end()) return {p,hit->second,nodes[hit->second].depth};
	            std::vector<Term> terms;
	            for(int bit=0;bit<width;bit++) if ((p.mask>>bit)&1) terms.push_back(raw(bit,(p.value>>bit)&1));
	            return reduce(terms,4);
	        }
	        auto score() const {return std::make_tuple(GetSize(nodes),maxdepth,depthsum);}
	    };
	    static int bits(Mask x) {return __builtin_popcountll(x);}
	    static Graph plan(const std::vector<Entry> &entries,const std::vector<Pred> &chosen,int width,size_t &work) {
	        Graph g;
	        Mask full=width==64?~Mask(0):(Mask(1)<<width)-1;
	        std::vector<Mask> covered(entries.size(),0);
	        std::vector<std::vector<Term>> terms(entries.size());
	        for (auto p:chosen) {
	            std::vector<int> uses;
	            for(int i=0;i<GetSize(entries);i++) {
	                work++;
	                if (!(covered[i]&p.mask) && (entries[i].value&p.mask)==p.value) uses.push_back(i);
	            }
	            if (uses.empty()) continue;
	            Term t=g.compare(p,width);
	            for(int i:uses) {covered[i]|=p.mask;terms[i].push_back(t);}
	        }
	        for(int i=0;i<GetSize(entries);i++) {
	            for(int bit=0;bit<width;bit++) {work++;if (!((covered[i]>>bit)&1)) terms[i].push_back(g.raw(bit,(entries[i].value>>bit)&1));}
	            Term root=g.reduce(terms[i],entries[i].capacity);
	            log_assert(root.p.mask==full && root.p.value==entries[i].value);
	            g.roots.push_back(root);g.maxdepth=std::max(g.maxdepth,root.depth);g.depthsum+=root.depth;
	        }
	        work+=g.nodes.size()*4;
	        return g;
	    }
	    static std::vector<Pred> candidates(const std::vector<Entry> &entries,int width,size_t &work) {
	        constexpr size_t MASK_LIMIT=256;
	        Mask full=width==64?~Mask(0):(Mask(1)<<width)-1;
	        std::set<Mask> masks;
	        auto add=[&](Mask m){if (bits(m)>=2 && masks.size()<MASK_LIMIT) masks.insert(m);};
	        auto cuts=[&](Mask m){
	            add(m);
	            std::vector<int> pos;
	            for(int b=0;b<width;b++) if ((m>>b)&1) pos.push_back(b);
	            if (GetSize(pos)<=12) {
	                for(int a=0;a<GetSize(pos);a++) for(int b=a+1;b<GetSize(pos);b++)
	                for(int c=b+1;c<GetSize(pos);c++) for(int d=c+1;d<GetSize(pos);d++)
	                    add((Mask(1)<<pos[a])|(Mask(1)<<pos[b])|(Mask(1)<<pos[c])|(Mask(1)<<pos[d]));
	            } else {
	                for(int start=0;start<GetSize(pos);start+=4) {
	                    Mask chunk=0;for(int j=start;j<std::min(start+4,GetSize(pos));j++) chunk|=Mask(1)<<pos[j];add(chunk);
	                }
	            }
	        };
	        std::map<std::vector<bool>,Mask> columns;
	        for(int b=0;b<width;b++) {
	            std::vector<bool> pattern;for(auto &e:entries) pattern.push_back((e.value>>b)&1);
	            columns[pattern]|=Mask(1)<<b;
	        }
	        Mask common=full;
	        for(auto &e:entries) common&=~(e.value^entries.front().value);
	        cuts(common&full);
	        for(auto &col:columns) cuts(col.second);
	        for(int a=0;a<GetSize(entries) && masks.size()<MASK_LIMIT;a++)
	            for(int b=a+1;b<GetSize(entries) && masks.size()<MASK_LIMIT;b++) {cuts(full&~(entries[a].value^entries[b].value));work+=width;}
	        std::vector<Pred> result;
	        for(Mask m:masks) {
	            std::map<Mask,int> count;for(auto &e:entries) count[e.value&m]++;
	            for(auto &kv:count) if (kv.second>=2) result.push_back({m,kv.first});
	        }
	        return result;
	    }
	    static bool optimize(Module *module,const SigSpec &input,std::vector<Entry> &entries,bool verbose) {
	        int width=GetSize(input);size_t work=0;
	        std::sort(entries.begin(),entries.end(),[](const Entry &a,const Entry &b){return a.cell->name.str()<b.cell->name.str();});
	        auto pool=candidates(entries,width,work);
	        std::vector<Pred> chosen;
	        Graph current=plan(entries,chosen,width,work);auto before=current.score();
	        constexpr size_t WORK_LIMIT=300000;
	        for(int round=0;round<16 && work<WORK_LIMIT;round++) {
	            bool found=false;Graph best;Pred best_pred{0,0};int best_uses=0;
	            std::vector<Mask> covered(entries.size(),0);
	            for(auto p:chosen) for(int i=0;i<GetSize(entries);i++)
	                if (!(covered[i]&p.mask) && (entries[i].value&p.mask)==p.value) covered[i]|=p.mask;
	            for(auto p:pool) {
	                int uses=0;
	                for(int i=0;i<GetSize(entries);i++) if (!(covered[i]&p.mask) && (entries[i].value&p.mask)==p.value) uses++;
	                if (uses<2) continue;
	                auto trial=chosen;trial.push_back(p);
	                Graph g=plan(entries,trial,width,work);
	                if (g.score()<current.score() && (!found || g.score()<best.score() || (g.score()==best.score() && uses>best_uses))) {
	                    found=true;best=std::move(g);best_pred=p;best_uses=uses;
	                }
	                if (work>=WORK_LIMIT) break;
	            }
	            if (!found) break;
	            chosen.push_back(best_pred);current=std::move(best);
	        }
	        if (chosen.empty()) return false;
	        std::vector<SigBit> signals;
	        for(auto &node:current.nodes) {
	            SigSpec a;std::vector<State> value;
	            for(auto &t:node.inputs) {
	                if (t.node>=0) {log_assert(t.node<GetSize(signals));a.append(signals[t.node]);value.push_back(State::S1);}
	                else {int bit=__builtin_ctzll(t.p.mask);a.append(input[bit]);value.push_back(t.p.value?State::S1:State::S0);}
	            }
	            SigBit y=module->addWire(NEW_ID);
	            module->addEq(NEW_ID,a,Const(value),y,false,entries.front().src);signals.push_back(y);
	        }
	        for(int i=0;i<GetSize(entries);i++) {
	            auto &root=current.roots[i];log_assert(root.node>=0);
	            module->connect(entries[i].y,signals[root.node]);module->remove(entries[i].cell);
	        }
	        if (verbose) {
	            log("  unified P3 %s: %d-bit / %d comparison(s), %d candidates, %d shared predicates, estimated %d -> %d LUTs, depth %d -> %d, work %zu.\n",log_id(module),width,GetSize(entries),GetSize(pool),GetSize(chosen),std::get<0>(before),GetSize(current.nodes),std::get<1>(before),current.maxdepth,work);
	            for(auto p:chosen) log("    shared mask=%llx value=%llx\n",(unsigned long long)p.mask,(unsigned long long)p.value);
	        }
	        return true;
	    }
	    static int run(Design *design, bool verbose) {
	        int changes=0;
	        for(auto module:design->selected_modules()) {
	            if (module->get_bool_attribute(ID::blackbox) || module->get_bool_attribute(ID::whitebox)) continue;
	            SigMap sigmap(module);
				pool<SigBit> controls,outputs;
	            for(auto w:module->wires()) if(w->port_output) for(auto b:sigmap(SigSpec(w))) outputs.insert(b);
	            for(auto c:module->cells()) if(c->type.in(ID($mux),ID($pmux))) for(auto b:sigmap(c->getPort(ID::S))) controls.insert(b);
	            std::map<SigSpec,std::vector<Entry>> families;
	            for(auto c:module->selected_cells()) {
	                if(c->type!=ID($eq) || c->get_bool_attribute(ID::keep)) continue;
	                SigSpec a=sigmap(c->getPort(ID::A)),b=sigmap(c->getPort(ID::B)),y=sigmap(c->getPort(ID::Y));
	                if (a.is_fully_const()) std::swap(a,b);
	                if(a.has_const() || !b.is_fully_def() || GetSize(a)<5 || GetSize(a)>64 || GetSize(y)!=1 || !y[0].wire) continue;
	                bool sign=c->getParam(ID::A_SIGNED).as_bool() && c->getParam(ID::B_SIGNED).as_bool();
	                if(GetSize(b)<GetSize(a)) b.extend_u0(GetSize(a),sign);
	                if(GetSize(b)!=GetSize(a)) continue;
	                Mask value=0;
					for(int bit=0;bit<GetSize(b);bit++) if(b[bit]==State::S1) value|=Mask(1)<<bit;
	                int capacity=controls.count(y[0]) && !outputs.count(y[0]) ? 2:4;
	                families[a].push_back({c,c->getPort(ID::Y),value,capacity,c->get_src_attribute()});
	            }
	            for(auto &f:families) if(GetSize(f.second)>=2 && GetSize(f.second)<=128) changes+=optimize(module,f.first,f.second,verbose);
	        }
	        return changes;
	    }
	};

	// P3 利用触发器使能的取值范围化简使能和数据逻辑。
	struct EnableDcRewriter {
		// 三值求值，64 组输入取值并行：某一位在 one 中为 1 表示值为 1，在 zero 中为 1 表示值为 0，都不是表示未知
		struct Val { uint64_t one = 0, zero = 0; };
		static constexpr int X = 2;
		struct EnInfo { Cell *ff; SigBit en; SigSpec sig; std::vector<int> enabled; };

		Module *module;
		SigMap sigmap;
		dict<SigBit, std::pair<Cell *, int>> drivers;
		dict<SigBit, Val> assign, memo;
		std::vector<EnInfo> infos;
		int budget = 0;

		EnableDcRewriter(Module *module) : module(module), sigmap(module)
		{
			for (auto cell : module->cells()) {
				if (!cell->type.in(ID($not), ID($and), ID($or), ID($xor), ID($xnor), ID($reduce_and), ID($reduce_or),
						ID($reduce_bool), ID($logic_not), ID($logic_and), ID($logic_or), ID($eq), ID($ne), ID($mux), ID($pmux)))
					continue;
				SigSpec y = sigmap(cell->getPort(ID::Y));
				for (int i = 0; i < GetSize(y); i++)
					if (y[i].wire)
						drivers[y[i]] = {cell, i};
			}
		}

		static Val cst(bool v) { return v ? Val{~0ULL, 0} : Val{0, ~0ULL}; }
		static Val inv(Val a) { return {a.zero, a.one}; }
		static Val and2(Val a, Val b) { return {a.one & b.one, a.zero | b.zero}; }
		static Val or2(Val a, Val b) { return {a.one | b.one, a.zero & b.zero}; }
		static Val xor2(Val a, Val b) { return {(a.one & b.zero) | (a.zero & b.one), (a.one & b.one) | (a.zero & b.zero)}; }

		Val ext(Cell *cell, IdString port, int k)
		{
			SigSpec s = cell->getPort(port);
			if (k < GetSize(s))
				return eval(s[k]);
			IdString sign = port == ID::A ? ID::A_SIGNED : ID::B_SIGNED;
			if (cell->hasParam(sign) && cell->getParam(sign).as_bool() && GetSize(s) > 0)
				return eval(s[GetSize(s) - 1]);
			return cst(false);
		}

		Val reduce(Cell *cell, IdString port, bool is_and)
		{
			Val r = cst(is_and);
			for (auto bit : cell->getPort(port))
				r = is_and ? and2(r, eval(bit)) : or2(r, eval(bit));
			return r;
		}

		Val eval_cell(Cell *cell, int k)
		{
			IdString t = cell->type;
			if (t == ID($not))
				return inv(ext(cell, ID::A, k));
			if (t.in(ID($and), ID($or), ID($xor), ID($xnor))) {
				Val a = ext(cell, ID::A, k), b = ext(cell, ID::B, k);
				if (t == ID($and))
					return and2(a, b);
				if (t == ID($or))
					return or2(a, b);
				return t == ID($xor) ? xor2(a, b) : inv(xor2(a, b));
			}
			if (t == ID($mux)) {
				Val s = eval(cell->getPort(ID::S)[0]);
				Val a = eval(cell->getPort(ID::A)[k]), b = eval(cell->getPort(ID::B)[k]);
				return {(s.zero & a.one) | (s.one & b.one) | (a.one & b.one),
					(s.zero & a.zero) | (s.one & b.zero) | (a.zero & b.zero)};
			}
			if (t == ID($pmux)) {
				SigSpec s = cell->getPort(ID::S);
				int width = GetSize(cell->getPort(ID::A));
				std::vector<Val> sel;
				uint64_t all_zero = ~0ULL;
				for (auto bit : s) {
					sel.push_back(eval(bit));
					all_zero &= sel.back().zero;
				}
				Val a = eval(cell->getPort(ID::A)[k]);
				Val r = {all_zero & a.one, all_zero & a.zero};
				for (int lane = 0; lane < GetSize(sel); lane++) {
					uint64_t only = sel[lane].one;
					for (int other = 0; other < GetSize(sel); other++)
						if (other != lane)
							only &= sel[other].zero;
					if (only == 0)
						continue;
					Val b = eval(cell->getPort(ID::B)[lane * width + k]);
					r.one |= only & b.one;
					r.zero |= only & b.zero;
				}
				return r;
			}
			// 以下单元只有第 0 位有意义
			if (k > 0)
				return cst(false);
			if (t.in(ID($reduce_and), ID($reduce_or), ID($reduce_bool)))
				return reduce(cell, ID::A, t == ID($reduce_and));
			if (t == ID($logic_not))
				return inv(reduce(cell, ID::A, false));
			if (t.in(ID($logic_and), ID($logic_or))) {
				Val a = reduce(cell, ID::A, false), b = reduce(cell, ID::B, false);
				return t == ID($logic_and) ? and2(a, b) : or2(a, b);
			}
			if (t.in(ID($eq), ID($ne))) {
				int width = std::max(GetSize(cell->getPort(ID::A)), GetSize(cell->getPort(ID::B)));
				Val eq = cst(true);
				for (int i = 0; i < width; i++)
					eq = and2(eq, inv(xor2(ext(cell, ID::A, i), ext(cell, ID::B, i))));
				return t == ID($eq) ? eq : inv(eq);
			}
			return Val();
		}

		Val eval(SigBit bit)
		{
			bit = sigmap(bit);
			if (!bit.wire)
				return bit.data == State::S0 ? cst(false) : bit.data == State::S1 ? cst(true) : Val();
			auto a = assign.find(bit);
			if (a != assign.end())
				return a->second;
			auto m = memo.find(bit);
			if (m != memo.end())
				return m->second;
			auto d = drivers.find(bit);
			if (d == drivers.end() || --budget < 0)
				return Val();
			memo[bit] = Val();
			Val v = eval_cell(d->second.first, d->second.second);
			memo[bit] = v;
			return v;
		}

		// 枚举 vars 的全部取值，返回 bit 在每种取值下的值（0、1 或 X），vars 以外的信号视为未知
		std::vector<int> eval_all(const std::vector<SigBit> &vars, SigBit bit)
		{
			int n = GetSize(vars), total = 1 << n;
            std::vector<int> result(total, X);
            uint64_t low_masks[6] = {};
            for (int i = 0; i < std::min(n, 6); i++) {
                int step = 1 << i;
                low_masks[i] = (~0ULL / ((1ULL << step) + 1)) << step;
            }
            for (int base = 0; base < total; base += 64) {
				assign.clear();
				memo.clear();
				budget = 2000;
				for (int i = 0; i < n; i++) {
                    uint64_t mask = i < 6 ? low_masks[i] : (((base >> i) & 1) ? ~0ULL : 0);
					assign[vars[i]] = {mask, ~mask};
				}
				Val v = eval(bit);
				for (int lane = 0; lane < 64 && base + lane < total; lane++)
					result[base + lane] = ((v.one >> lane) & 1) ? 1 : ((v.zero >> lane) & 1) ? 0 : X;
			}
			return result;
		}

		// 收集 root 的组合输入锥：锥内的单元和叶子信号
		void cone(SigBit root, pool<Cell *> &cells, pool<SigBit> &leaves)
		{
			std::vector<SigBit> stack = {sigmap(root)};
			pool<SigBit> seen;
			while (!stack.empty()) {
				SigBit bit = stack.back();
				stack.pop_back();
				if (!bit.wire || seen.count(bit))
					continue;
				seen.insert(bit);
				auto d = drivers.find(bit);
				if (d == drivers.end()) {
					leaves.insert(bit);
					continue;
				}
				Cell *cell = d->second.first;
				if (cells.count(cell))
					continue;
				cells.insert(cell);
				for (auto &conn : cell->connections())
					if (cell->input(conn.first))
						for (auto b : sigmap(conn.second))
							stack.push_back(b);
			}
		}

		// 比较单元 cell 是否为 sig == 常量，是则返回常量值
		bool decode_eq(Cell *cell, const SigSpec &sig, int &value)
		{
			if (cell->type != ID($eq))
				return false;
			SigSpec a = sigmap(cell->getPort(ID::A)), b = sigmap(cell->getPort(ID::B));
			if (a.is_fully_const())
				std::swap(a, b);
			if (a != sig || !b.is_fully_def() || GetSize(b) > GetSize(sig))
				return false;
			value = 0;
			for (int i = 0; i < GetSize(b); i++)
				if (b[i] == RTLIL::SigBit(RTLIL::State::S1))
					value |= 1 << i;
			return true;
		}

		// 在使能的输入锥中找与常量比较的信号，取出现次数最多的一个
		SigSpec select_signal(SigBit en)
		{
			dict<SigSpec, int> count;
			pool<SigBit> seen;
			std::vector<SigBit> stack = {sigmap(en)};
			while (!stack.empty() && GetSize(seen) < 64) {
				SigBit bit = stack.back();
				stack.pop_back();
				if (!bit.wire || seen.count(bit))
					continue;
				seen.insert(bit);
				auto d = drivers.find(bit);
				if (d == drivers.end())
					continue;
				Cell *cell = d->second.first;
				if (cell->type.in(ID($eq), ID($ne), ID($logic_not))) {
					SigSpec a = sigmap(cell->getPort(ID::A));
					SigSpec b = cell->type == ID($logic_not) ? SigSpec() : sigmap(cell->getPort(ID::B));
					if (a.is_fully_const())
						std::swap(a, b);
					if (b.is_fully_const() && !a.has_const())
						count[a]++;
					continue;
				}
				for (auto &conn : cell->connections())
					if (cell->input(conn.first))
						for (auto b : sigmap(conn.second))
							stack.push_back(b);
			}
			SigSpec best;
			int best_count = 0;
			for (auto &it : count) {
				int width = GetSize(it.first);
				if (width < 2 || width > 8 || GetSize(it.first.to_sigbit_pool()) != width)
					continue;
				if (it.second > best_count) {
					best = it.first;
					best_count = it.second;
				}
			}
			return best;
		}

		int run(bool verbose)
		{
			int changes = 0;
			for (auto cell : module->selected_cells()) {
				if (!cell->type.in(ID($dffe), ID($adffe), ID($aldffe), ID($sdffe), ID($sdffce), ID($dffsre)))
					continue;
				SigBit en = sigmap(cell->getPort(ID::EN))[0];
				bool en_pol = cell->getParam(ID::EN_POLARITY).as_bool();
				SigSpec sig = select_signal(en);
				if (sig.empty())
					continue;

				//枚举 sig 的全部取值，保留使能可能有效的取值
				int width = GetSize(sig);
				std::vector<SigBit> vars = sig.to_sigbit_vector();
				std::vector<int> en_value = eval_all(vars, en);
				std::vector<int> enabled;
				for (int value = 0; value < (1 << width); value++)
					if (en_value[value] != (en_pol ? 0 : 1))
						enabled.push_back(value);
				if (en_pol)
					infos.push_back({cell, en, sig, enabled});
				if (enabled.empty() || GetSize(enabled) == (1 << width))
					continue;

				SigSpec d = cell->getPort(ID::D), new_d = d;
				int rewired = 0;
				for (int i = 0; i < GetSize(d); i++) {
					SigBit bit = sigmap(d[i]);
					if (!drivers.count(bit))
						continue;
					std::vector<int> d_value = eval_all(vars, bit);
					bool known = true;
					for (int value : enabled)
						if (d_value[value] == X)
							known = false;
					if (!known)
						continue;
					for (int j = 0; j < width; j++) {
						bool match = true;
						for (int n = 0; n < GetSize(enabled) && match; n++)
							match = ((enabled[n] >> j) & 1) == d_value[enabled[n]];
						if (match) {
							new_d[i] = sig[j];
							rewired++;
							break;
						}
					}
				}
				if (rewired == 0)
					continue;
				cell->setPort(ID::D, new_d);
				changes++;
				if (verbose)
					log("  P3 %s.%s: rewired %d data bit(s) under enable don't-care (%d of %d values of %s enabled).\n",
						log_id(module), log_id(cell), rewired, GetSize(enabled), 1 << width, log_signal(sig));
			}
			return changes;
		}

		// 必须在 run 之后调用，使用 run 记录的各使能取值范围
		int reuse_enables(bool verbose)
		{
			dict<SigBit, int> users;
			for (auto cell : module->cells())
				for (auto &conn : cell->connections())
					if (cell->input(conn.first))
						for (auto b : sigmap(conn.second))
							users[b]++;
			for (auto w : module->wires())
				if (w->port_output)
					for (auto b : sigmap(SigSpec(w)))
						users[b]++;

			int changes = 0;
			pool<SigBit> rewritten;
			for (auto &t : infos) {
				if (rewritten.count(t.en))
					continue;
				pool<Cell *> t_cells;
				pool<SigBit> t_leaves;
				cone(t.en, t_cells, t_leaves);
				bool done = false;
				for (auto consumer : t_cells) {
					if (done)
						break;
					//只处理单独使用的比较：同一单元中没有别的与 sig 比较的输入，且输出只有一处使用
					std::vector<std::tuple<IdString, int, int>> uses;
					for (auto &conn : consumer->connections()) {
						if (!consumer->input(conn.first))
							continue;
						for (int i = 0; i < GetSize(conn.second); i++) {
							auto d = drivers.find(sigmap(conn.second[i]));
							int value;
							if (d != drivers.end() && decode_eq(d->second.first, t.sig, value))
								uses.push_back(std::make_tuple(conn.first, i, value));
						}
					}
					if (GetSize(uses) != 1)
						continue;
					bool single_use = true;
					for (auto b : sigmap(consumer->getPort(ID::Y)))
						if (users[b] != 1)
							single_use = false;
					if (!single_use)
						continue;
					IdString port = std::get<0>(uses[0]);
					int idx = std::get<1>(uses[0]), key = std::get<2>(uses[0]);

					for (auto &s : infos) {
						if (s.en == t.en || s.sig != t.sig || rewritten.count(s.en) || GetSize(s.enabled) > 4 ||
								std::find(s.enabled.begin(), s.enabled.end(), key) == s.enabled.end())
							continue;
						//区分位：K 与 s 的其他可能取值在这一位上都不同，优先 K 为 1 的位
						int bit = -1;
						for (int want = 1; want >= 0 && bit < 0; want--)
							for (int j = 0; j < GetSize(t.sig) && bit < 0; j++) {
								if (((key >> j) & 1) != want)
									continue;
								bool ok = true;
								for (int v : s.enabled)
									if (v != key && ((v >> j) & 1) == want)
										ok = false;
								if (ok)
									bit = j;
							}
						if (bit < 0)
							continue;
						pool<Cell *> s_cells;
						pool<SigBit> s_leaves;
						cone(s.en, s_cells, s_leaves);
						if (s_cells.count(consumer))
							continue;

						//枚举目标使能的全部输入，核对替换前后的值
						pool<SigBit> support = t_leaves;
						for (auto b : s_leaves)
							support.insert(b);
						if (GetSize(support) > 12)
							continue;
						std::vector<SigBit> vars(support.begin(), support.end());
						std::vector<int> before = eval_all(vars, t.en);

						SigSpec lit = t.sig[bit];
						Cell *not_cell = nullptr;
						if (((key >> bit) & 1) == 0) {
							Wire *n = module->addWire(NEW_ID);
							not_cell = module->addNot(NEW_ID, lit, n);
							drivers[SigBit(n)] = {not_cell, 0};
							lit = n;
						}
						Wire *w = module->addWire(NEW_ID);
						Cell *and_cell = module->addAnd(NEW_ID, s.en, lit, w);
						drivers[SigBit(w)] = {and_cell, 0};
						SigSpec old_port = consumer->getPort(port), new_port = old_port;
						new_port[idx] = w;
						consumer->setPort(port, new_port);

						std::vector<int> after = eval_all(vars, t.en);
						bool same = true;
						for (int value = 0; value < GetSize(after) && same; value++)
							same = after[value] != X && after[value] == before[value];
						if (!same) {
							consumer->setPort(port, old_port);
							drivers.erase(SigBit(w));
							module->remove(and_cell);
							if (not_cell) {
								drivers.erase(sigmap(not_cell->getPort(ID::Y))[0]);
								module->remove(not_cell);
							}
							continue;
						}
						rewritten.insert(t.en);
						changes++;
						done = true;
						if (verbose)
							log("  P3 %s.%s: enable reuses %s.EN & %s%s for %s == %d.\n",
								log_id(module), log_id(t.ff), log_id(s.ff), not_cell ? "!" : "",
								log_signal(t.sig[bit]), log_signal(t.sig), key);
						break;
					}
				}
			}
			return changes;
		}
	};

	//P3入口
	static int run_compare_share_rule(RTLIL::Design *design, bool verbose)
	{
		int changes = 0;
		for (auto module : design->selected_modules()) {
			if (module->get_bool_attribute(ID::blackbox) || module->get_bool_attribute(ID::whitebox))
				continue;
			EnableDcRewriter rewriter(module);
			changes += rewriter.run(verbose);
			changes += rewriter.reuse_enables(verbose);
		}
		return changes + ComparePlanner::run(design, verbose);
	}

	struct RomFunction {
		std::vector<int> inputs;
		std::uint32_t truth = 0;
		bool inverted = false;
	};

	static std::uint32_t rom_truth_mask(int inputs)
	{
		log_assert(inputs >= 0 && inputs <= 5);
		return inputs == 5 ? UINT32_C(0xffffffff) : (UINT32_C(1) << (1 << inputs)) - 1;
	}

	static RTLIL::Const rom_truth_const(int inputs, std::uint32_t truth)
	{
		std::vector<RTLIL::State> bits(1 << inputs, RTLIL::State::S0);
		for (int index = 0; index < GetSize(bits); index++)
			if ((truth >> index) & 1)
				bits[index] = RTLIL::State::S1;
		return RTLIL::Const(bits);
	}

	//剔除每bit输出的无关输入位/消除冗余输入；规范化与反向复用
	static RomFunction normalize_rom_function(RomFunction function)
	{
		int width = GetSize(function.inputs);
		std::uint32_t truth = function.truth ^ (function.inverted ? rom_truth_mask(width) : 0);
		std::vector<int> support;
		for (int bit = 0; bit < width; bit++) {
			bool depends = false;
			for (int index = 0; index < (1 << width); index++)
				if (((truth >> index) & 1) != ((truth >> (index ^ (1 << bit))) & 1))
					depends = true;
			if (depends)
				support.push_back(bit);
		}
		RomFunction result;
		for (int bit : support)
			result.inputs.push_back(function.inputs[bit]);
		for (int index = 0; index < (1 << GetSize(support)); index++) {
			int original_index = 0;
			for (int bit = 0; bit < GetSize(support); bit++)
				original_index |= ((index >> bit) & 1) << support[bit];
			if ((truth >> original_index) & 1)
				result.truth |= UINT32_C(1) << index;
		}

		if (result.inputs.empty()) {
			result.inverted = result.truth != 0;
			result.truth = 0;
		} else if (GetSize(result.inputs) == 1) {
			result.inverted = result.truth == 1;
			result.truth = 2;
		} else {
			std::uint32_t complement = result.truth ^ rom_truth_mask(GetSize(result.inputs));
			if (complement < result.truth) {
				result.truth = complement;
				result.inverted = true;
			}
		}
		return result;
	}

	static RomFunction rom_cofactor(RomFunction function, int address_bit, bool value)
	{
		int position = -1;
		RomFunction result;
		for (int bit = 0; bit < GetSize(function.inputs); bit++) {
			if (function.inputs[bit] == address_bit)
				position = bit;
			else
				result.inputs.push_back(function.inputs[bit]);
		}
		log_assert(position >= 0);
		std::uint32_t truth = function.truth ^ (function.inverted ? rom_truth_mask(GetSize(function.inputs)) : 0);
		for (int index = 0; index < (1 << GetSize(result.inputs)); index++) {
			int low = index & ((1 << position) - 1);
			int high = (index >> position) << (position + 1);
			int original_index = low | high | (int(value) << position);
			if ((truth >> original_index) & 1)
				result.truth |= UINT32_C(1) << index;
		}
		return normalize_rom_function(result);
	}

	static RTLIL::SigSpec rom_function_key(const RomFunction &function, const RTLIL::SigSpec &address)
	{
		RTLIL::SigSpec key;
		for (int bit : function.inputs)
			key.append(address[bit]);
		key.append(rom_truth_const(GetSize(function.inputs), function.truth));
		return key;
	}

	struct RomPlanCost {
		int luts = 0;
		int pins = 0;
	};

	static RomPlanCost rom_plan_cost(const std::vector<RomFunction> &functions,
			const RTLIL::SigSpec &address, int split)
	{
		pool<RTLIL::SigSpec> leaves, roots;
		RomPlanCost cost;
		auto count_leaf = [&](const RomFunction &leaf) {
			if (GetSize(leaf.inputs) <= 1)
				return;
			auto key = rom_function_key(leaf, address);
			if (!leaves.count(key)) {
				leaves.insert(key);
				cost.luts++;
				cost.pins += GetSize(leaf.inputs);
			}
		};
		for (auto function : functions) {
			if (GetSize(function.inputs) <= 4) {
				count_leaf(function);
				continue;
			}

			function.inverted = false;
			auto key = rom_function_key(function, address);
			if (!roots.count(key)) {
				roots.insert(key);
				cost.luts++;
				cost.pins += 3;
				count_leaf(rom_cofactor(function, split, false));
				count_leaf(rom_cofactor(function, split, true));
			}
		}
		return cost;
	}

	struct RomEmitter {
		RTLIL::Module *module;
		RTLIL::SigSpec address;
		std::string src;
		int split;
		dict<RTLIL::SigSpec, RTLIL::SigBit> functions;
		dict<RTLIL::SigBit, RTLIL::SigBit> inverses;
		int luts = 0, muxes = 0;

		RomEmitter(RTLIL::Module *module, RTLIL::SigSpec address, std::string src, int split)
			: module(module), address(address), src(src), split(split) { }

		RTLIL::SigBit invert(RTLIL::SigBit bit)
		{
			if (bit.wire == nullptr)
				return RTLIL::SigBit(bit.data == RTLIL::State::S0 ? RTLIL::State::S1 : RTLIL::State::S0);
			auto cached = inverses.find(bit);
			if (cached != inverses.end())
				return cached->second;
			RTLIL::SigBit output(module->addWire(NEW_ID, 1));
			module->addNot(NEW_ID, bit, output, false, src);
			inverses.emplace(bit, output);
			return output;
		}

		RTLIL::SigBit emit(const RomFunction &function)
		{
			RTLIL::SigBit output;
			int width = GetSize(function.inputs);
			if (width == 0) {
				output = RTLIL::SigBit(RTLIL::State::S0);
			} else if (width == 1) {
				output = address[function.inputs[0]];
			} else {
				auto key = rom_function_key(function, address);
				auto cached = functions.find(key);
				if (cached != functions.end()) {
					output = cached->second;
				} else {
					output = RTLIL::SigBit(module->addWire(NEW_ID, 1));
					if (width <= 4) {
						RTLIL::SigSpec input;
						for (int bit : function.inputs)
							input.append(address[bit]);
						module->addLut(NEW_ID, input, output, rom_truth_const(width, function.truth), src);
						luts++;
					} else {
						RomFunction canonical = function;
						canonical.inverted = false;
						auto low = emit(rom_cofactor(canonical, split, false));
						auto high = emit(rom_cofactor(canonical, split, true));
						module->addMux(NEW_ID, low, high, address[split], output, src);
						muxes++;
					}
					functions.emplace(key, output);
				}
			}
			return function.inverted ? invert(output) : output;
		}
	};

    struct RomLutPlanner {
        struct Node {std::vector<int> in; unsigned tt=0;};
        std::vector<Node> nodes=std::vector<Node>(6);
        std::map<std::pair<std::vector<int>,unsigned>,int> cache;
        std::map<int,std::vector<int>> cones;
        int lut(std::vector<int> ins,unsigned truth) {
            log_assert(ins.size() <= 4);
            std::vector<int> bases;
            for(int r:ins) if(r/2) bases.push_back(r/2);
            std::sort(bases.begin(),bases.end()); bases.erase(std::unique(bases.begin(),bases.end()),bases.end());
            unsigned table=0;
            for(int j=0;j<(1<<int(bases.size()));j++) {
                int idx=0;
                for(int k=0;k<int(ins.size());k++) {
                    int r=ins[k],v=r&1;
                    if(r/2) v^=(j>>int(std::lower_bound(bases.begin(),bases.end(),r/2)-bases.begin()))&1;
                    idx|=v<<k;
                }
                table|=((truth>>idx)&1)<<j;
            }
            std::vector<int> support;
            for(int k=0;k<int(bases.size());k++) {
                bool used=false;
                for(int j=0;j<(1<<int(bases.size()));j++) if(((table>>j)&1)!=((table>>(j^(1<<k)))&1)) used=true;
                if(used) support.push_back(k);
            }
            unsigned reduced=0; std::vector<int> rem;
            for(int k:support) rem.push_back(bases[k]);
            for(int j=0;j<(1<<int(support.size()));j++) {
                int idx=0; for(int k=0;k<int(support.size());k++) idx|=((j>>k)&1)<<support[k];
                reduced|=((table>>idx)&1)<<j;
            }
            if(rem.empty()) return reduced;
            if(rem.size()==1) return rem[0]*2+(reduced==1);
            unsigned mask=(1u<<(1<<int(rem.size())))-1; bool inv=(reduced^mask)<reduced;
            if(inv) reduced^=mask;
            auto key=std::make_pair(rem,reduced);auto it=cache.find(key);
            if(it!=cache.end()) return it->second*2+inv;
            int id=int(nodes.size());nodes.push_back({rem,reduced});cache[key]=id;return id*2+inv;
        }
        const std::vector<int>& cone(int ref) {
            int id=ref/2;auto it=cones.find(id);if(it!=cones.end()) return it->second;
            std::set<int> all;
            if(id>5) {all.insert(id);for(int c:nodes[id].in) {auto &sub=cone(c*2);all.insert(sub.begin(),sub.end());}}
            return cones.emplace(id,std::vector<int>(all.begin(),all.end())).first->second;
        }
        int eval(int ref,int input) {
            int id=ref/2,y=0;
            if(id && id<=5) y=(input>>(id-1))&1;
            else if(id>5) {int index=0;for(int k=0;k<int(nodes[id].in.size());k++) index|=eval(nodes[id].in[k]*2,input)<<k;y=(nodes[id].tt>>index)&1;}
            return y^(ref&1);
        }
        std::vector<int> options(uint32_t f) {
            std::vector<int> opts;
            for(int s=0;s<5;s++) {
                std::vector<int> rem;for(int i=0;i<5;i++) if(i!=s) rem.push_back(i);
                std::vector<int> leaf;
                for(int v=0;v<2;v++) {
                    unsigned tt=0;for(int j=0;j<16;j++) {int idx=v<<s;for(int k=0;k<4;k++) idx|=((j>>k)&1)<<rem[k];tt|=((f>>idx)&1)<<j;}
                    std::vector<int> ins;for(int i:rem) ins.push_back((i+1)*2);leaf.push_back(lut(ins,tt));
                }
                opts.push_back(lut({leaf[0],leaf[1],(s+1)*2},0xca));
            }
            for(int mask=0;mask<32;mask++) if(__builtin_popcount(unsigned(mask))==3) {
                std::vector<int> direct,bound;for(int b=0;b<5;b++) ((mask>>b)&1 ? direct : bound).push_back(b);
                for(int sm=0;sm<8;sm++) if(__builtin_popcount(unsigned(sm))<=2) {
                    std::vector<int> shared,free;for(int k=0;k<3;k++) ((sm>>k)&1 ? shared : free).push_back(direct[k]);
                    std::vector<std::vector<unsigned>> columns,unique;bool valid=true;
                    for(int sv=0;sv<(1<<int(shared.size()));sv++) {
                        std::vector<unsigned> col;
                        for(int bv=0;bv<4;bv++) {
                            unsigned c=0;
                            for(int fv=0;fv<(1<<int(free.size()));fv++) {
                                int idx=0;for(int k=0;k<int(shared.size());k++) idx|=((sv>>k)&1)<<shared[k];
                                for(int k=0;k<2;k++) idx|=((bv>>k)&1)<<bound[k];
                                for(int k=0;k<int(free.size());k++) idx|=((fv>>k)&1)<<free[k];
                                c|=((f>>idx)&1)<<fv;
                            }
                            col.push_back(c);
                        }
                        auto u=col;std::sort(u.begin(),u.end());u.erase(std::unique(u.begin(),u.end()),u.end());
                        if(u.size()>2) {valid=false;break;}
                        columns.push_back(col);unique.push_back(u);
                    }
                    if(!valid) continue;
                    for(int pol=0;pol<(1<<int(columns.size()));pol++) {
                        std::vector<int> gi=bound;gi.insert(gi.end(),shared.begin(),shared.end());unsigned gt=0;
                        for(int j=0;j<(1<<int(gi.size()));j++) {
                            int sv=j>>2,bv=j&3,code=int(std::lower_bound(unique[sv].begin(),unique[sv].end(),columns[sv][bv])-unique[sv].begin())^((pol>>sv)&1);
                            gt|=code<<j;
                        }
                        std::vector<int> ins;for(int b:gi) ins.push_back((b+1)*2);int g=lut(ins,gt);unsigned ht=0;
                        for(int j=0;j<16;j++) {
                            int dv=j>>1,sv=0,fv=0;
                            for(int k=0;k<int(shared.size());k++) sv|=((dv>>int(std::find(direct.begin(),direct.end(),shared[k])-direct.begin()))&1)<<k;
                            for(int k=0;k<int(free.size());k++) fv|=((dv>>int(std::find(direct.begin(),direct.end(),free[k])-direct.begin()))&1)<<k;
                            int code=(j&1)^((pol>>sv)&1);unsigned col=unique[sv][code<int(unique[sv].size()) ? code : 0];ht|=((col>>fv)&1)<<j;
                        }
                        ins={g};for(int b:direct) ins.push_back((b+1)*2);opts.push_back(lut(ins,ht));
                    }
                }
            }

            std::set<int> seen(opts.begin(),opts.begin()+5);std::vector<int> result(opts.begin(),opts.begin()+5);
            for(int i=5;i<int(opts.size());i++) if(seen.insert(opts[i]).second) result.push_back(opts[i]);
            for(int r:result) for(int i=0;i<32;i++) log_assert(eval(r,i)==int((f>>i)&1));
            return result;
        }
        std::vector<int> plan(const std::vector<std::vector<int>> &choices) {
            for(auto &c:choices) for(int r:c) cone(r);
            auto score=[&](const std::vector<int> &plan) {
                std::set<int> union_nodes;
                for(int i=0;i<int(plan.size());i++) {
                    auto &sub=cone(choices[i][plan[i]]);union_nodes.insert(sub.begin(),sub.end());
                }
                int pins=0;for(int n:union_nodes) pins+=int(nodes[n].in.size());
                return std::make_tuple(int(union_nodes.size()),0,pins);
            };
            std::vector<int> winner(choices.size(),0);auto best=score(winner);
            int best_start=0;auto initial_best=best;
            for(int s=1;s<5;s++) {auto c=score(std::vector<int>(choices.size(),s));if(c<initial_best) {initial_best=c;best_start=s;}}
            {
                std::vector<int> p(choices.size(),best_start);
                auto s=score(p);
                for(int sweep=0;sweep<8;sweep++) {
                    bool changed=false;
                    for(int i=0;i<int(p.size());i++) {
                        int initial=p[i],choice=initial;auto local=s;

                        std::vector<int> counts(nodes.size(),0);int area=0,pins=0;
                        auto adjust=[&](int r,int delta) {
                            for(int n:cone(r)) {int before=counts[n];counts[n]+=delta;if(before==0 && counts[n]>0) {area++;pins+=int(nodes[n].in.size());}if(before>0 && counts[n]==0) {area--;pins-=int(nodes[n].in.size());}}
                        };
                        for(int j=0;j<int(p.size());j++) adjust(choices[j][p[j]],1);
                        adjust(choices[i][initial],-1);
                        for(int k=0;k<int(choices[i].size());k++) {
                            adjust(choices[i][k],1);
                            auto trial=std::make_tuple(area,0,pins);
                            if(trial<local) {local=trial;choice=k;}
                            adjust(choices[i][k],-1);
                        }
                        p[i]=choice;changed|=choice!=initial;s=local;
                    }
                    if(!changed) break;
                }
                if(s<best) {best=s;winner=p;}
            }
            
            return winner;
        }
    };

	static int run_rom_decompose_rule(RTLIL::Design *design, bool verbose)
	{
		int changes = 0;
		for (auto module : design->selected_modules()) {
			SigMap sigmap(module);
			std::vector<RTLIL::Cell *> candidates;
			for (auto cell : module->selected_cells())
				if (cell->type == ID($mem_v2) && !cell->get_bool_attribute(ID::keep))
					candidates.push_back(cell);
			for (auto cell : candidates) {
				int abits = cell->getParam(ID::ABITS).as_int();
				int width = cell->getParam(ID::WIDTH).as_int();

				//筛选符合优化条件的异步小ROM
				if (abits < 1 || abits > 5 || width < 1 || width > 64 ||
					cell->getParam(ID::SIZE).as_int() != (1 << abits) ||
					cell->getParam(ID::OFFSET).as_int() != 0 ||
					cell->getParam(ID::WR_PORTS).as_int() != 0 ||
					cell->getParam(ID::RD_PORTS).as_int() != 1 ||
					cell->getParam(ID::RD_CLK_ENABLE).as_bool() ||
					cell->getParam(ID::RD_WIDE_CONTINUATION).as_bool())
					continue;
				if (sigmap(cell->getPort(ID::RD_EN)) != RTLIL::SigSpec(RTLIL::State::S1) ||
					sigmap(cell->getPort(ID::RD_ARST)) != RTLIL::SigSpec(RTLIL::State::S0) ||
					sigmap(cell->getPort(ID::RD_SRST)) != RTLIL::SigSpec(RTLIL::State::S0))
					continue;
				RTLIL::Const init = cell->getParam(ID::INIT);
				RTLIL::SigSpec address = sigmap(cell->getPort(ID::RD_ADDR));
				RTLIL::SigSpec data = cell->getPort(ID::RD_DATA);
				if (GetSize(address) != abits || GetSize(data) != width ||
					GetSize(init) != width * (1 << abits) || !init.is_fully_def())
					continue;
				pool<RTLIL::SigBit> address_bits;
				bool valid = true;
				for (auto bit : address) {
					if (bit.wire == nullptr || address_bits.count(bit))
						valid = false;
					address_bits.insert(bit);
				}
				for (auto bit : data)
					if (bit.wire == nullptr)
						valid = false;
				if (!valid)
					continue;
				//提取真值表；规范化
				std::vector<RomFunction> functions;
				for (int bit = 0; bit < width; bit++) {
					RomFunction function;
					for (int index = 0; index < abits; index++)
						function.inputs.push_back(index);
					for (int index = 0; index < (1 << abits); index++)
						if (init[index * width + bit] == RTLIL::State::S1)
							function.truth |= UINT32_C(1) << index;
					functions.push_back(normalize_rom_function(function));
				}

                if (abits == 5) {
                    RomLutPlanner dag;
                    std::vector<std::vector<int>> choices;
                    std::map<uint32_t,std::vector<int>> option_cache;
                    for (auto f : functions) {
                        uint32_t truth=0;
                        for(int i=0;i<32;i++) {
                            int pos=0; for(int k=0;k<GetSize(f.inputs);k++) pos|=((i>>f.inputs[k])&1)<<k;
                            truth|=(((f.truth>>pos)&1)^f.inverted)<<i;
                        }
                        auto it=option_cache.find(truth);
                        if(it==option_cache.end()) it=option_cache.emplace(truth,dag.options(truth)).first;
                        choices.push_back(it->second);
                    }
                    auto plan=dag.plan(choices);
                    bool accept=true;
                    {
                        int old_cost=rom_plan_cost(functions,address,0).luts;
                        for(int s=1;s<5;s++) old_cost=std::min(old_cost,rom_plan_cost(functions,address,s).luts);
                        std::set<int> union_nodes;
                        for(int i=0;i<GetSize(choices);i++) {auto &cone=dag.cone(choices[i][plan[i]]);union_nodes.insert(cone.begin(),cone.end());}
                        int saving=old_cost-int(union_nodes.size());
                        accept=saving>=std::max(2,(old_cost+7)/8);
                        if (verbose)
                            log("  P4 %s.%s: functional candidate %d -> %d estimated LUT(s), accept %d.\n",
                                log_id(module), log_id(cell), old_cost, int(union_nodes.size()), int(accept));
                    }
                    if(accept) {
                    dict<int,RTLIL::SigBit> emitted;
                    std::function<RTLIL::SigBit(int)> emit = [&](int ref) -> RTLIL::SigBit {
                        if(ref<2) return RTLIL::SigBit(ref ? RTLIL::State::S1 : RTLIL::State::S0);
                        if(emitted.count(ref)) return emitted.at(ref);
                        if(ref&1) {
                            auto a=emit(ref^1); RTLIL::SigBit y(module->addWire(NEW_ID,1));
                            module->addNot(NEW_ID,a,y,false,cell->get_src_attribute()); emitted[ref]=y; return y;
                        }
                        int id=ref/2;
                        if(id<=5) return address[id-1];
                        auto n=dag.nodes.at(id); RTLIL::SigSpec ins;
                        for(int child:n.in) ins.append(emit(child*2));
                        RTLIL::SigBit y(module->addWire(NEW_ID,1)); std::vector<RTLIL::State> bits;
                        for(int i=0;i<(1<<GetSize(n.in));i++) bits.push_back((n.tt>>i)&1 ? RTLIL::State::S1 : RTLIL::State::S0);
                        module->addLut(NEW_ID,ins,y,RTLIL::Const(bits),cell->get_src_attribute()); emitted[ref]=y; return y;
                    };
                    RTLIL::SigSpec replacement;
                    for(int i=0;i<GetSize(choices);i++) replacement.append(emit(choices[i][plan[i]]));
                    if (verbose)
                        log("  P4 %s.%s: emitted shared two-level functional decomposition.\n", log_id(module), log_id(cell));
                    module->connect(data,replacement); module->remove(cell); changes++; continue;
                    }
                }
				int best_split = 0;
				RomPlanCost best = rom_plan_cost(functions, address, 0);
				if (verbose)
					log("  P4 %s.%s: address bit 0, estimated %d LUT(s), %d input pin(s).\n",
						log_id(module), log_id(cell), best.luts, best.pins);
				for (int split = 1; split < abits; split++) {
					auto cost = rom_plan_cost(functions, address, split);
					if (verbose)
						log("  P4 %s.%s: address bit %d, estimated %d LUT(s), %d input pin(s).\n",
							log_id(module), log_id(cell), split, cost.luts, cost.pins);
					if (cost.luts < best.luts || (cost.luts == best.luts && cost.pins < best.pins)) {
						best = cost;
						best_split = split;
					}
				}

				
				RomEmitter emitter(module, address, cell->get_src_attribute(), best_split);
				RTLIL::SigSpec replacement;
				for (const auto &function : functions)
					replacement.append(emitter.emit(function));
				module->connect(data, replacement);
				log("  P4 %s.%s: decomposed %dx%d ROM, split address bit %d; %d leaf LUT(s), %d shared mux root(s), estimated %d LUT(s).\n",
					log_id(module), log_id(cell), 1 << abits, width, best_split,
					emitter.luts, emitter.muxes, best.luts);
				module->remove(cell);
				changes++;
			}
		}
		return changes;
	}

	void execute(std::vector<std::string> args, RTLIL::Design *design) override
	{
		//规则开关
		bool enable_group = false;
		bool enable_priority_balance = false;
		bool enable_compare_share = false;
		bool enable_rom_decompose = false;
		bool enable_region = false;


		bool explicit_rule_selection = false;
		bool verbose = false;

		size_t argidx;
		for (argidx = 1; argidx < args.size(); argidx++) {
			if (args[argidx] == "-p1" || args[argidx] == "-group") {
				explicit_rule_selection = true;
				enable_group = true;
				continue;
			}
			if (args[argidx] == "-p2") {
				explicit_rule_selection = true;
				enable_priority_balance = true;
				continue;
			}
			if (args[argidx] == "-p3") {
				explicit_rule_selection = true;
				enable_compare_share = true;
				continue;
			}
			if (args[argidx] == "-p4") {
				explicit_rule_selection = true;
				enable_rom_decompose = true;
				continue;
			}
			if (args[argidx] == "-p5") {
				explicit_rule_selection = true;
				enable_region = true;
				continue;
			}
			if (args[argidx] == "-all") {
				enable_region = true;
				explicit_rule_selection = true;
				enable_group = true;
				enable_priority_balance = true;
				enable_compare_share = true;
				enable_rom_decompose = true;
				continue;
			}
			if (args[argidx] == "-v" || args[argidx] == "-verbose") {
				verbose = true;
				continue;
			}
			break;
		}

		//未指定规则时默认全开
		if (!explicit_rule_selection) {
			enable_region = true;
			enable_group = true;
			enable_priority_balance = true;
			enable_compare_share = true;
			enable_rom_decompose = true;
		}

		extra_args(args, argidx, design);
		log_header(design, "Executing PMUX_OPT pass.\n");

		int module_count = 0;
		int pmux_count = 0;
		for (auto module : design->selected_modules()) {
			module_count++;
			for (auto cell : module->selected_cells())
				if (cell->type == ID($pmux))
					pmux_count++;
		}

		std::string enabled_rules;
		if (enable_group)
			enabled_rules += " P1(group)";
		if (enable_priority_balance)
			enabled_rules += " P2(priority-balance)";
		if (enable_compare_share)
			enabled_rules += " P3(unified-compare-share)";
		if (enable_rom_decompose)
			enabled_rules += " P4(rom-decompose)";
		if (enable_region)
			enabled_rules += " P5(complete-decoder-region)";
		if (enabled_rules.empty())
			enabled_rules = " (none)";

		log("  Enabled rules:%s\n", enabled_rules.c_str());
		log("  Selected design contains %d $pmux cell(s) in %d module(s).\n",
			pmux_count, module_count);

		int changes = 0;
		if (enable_group)
			changes += run_group_rule(design, verbose);
		if (enable_priority_balance)
			changes += run_priority_balance_rule(design, verbose);
		if (enable_compare_share)
			changes += run_compare_share_rule(design, verbose);
		if (enable_rom_decompose)
			changes += run_rom_decompose_rule(design, verbose);

		if (enable_region) {
			int region_changes = PmuxCompleteDecoderRegion::run(design, verbose);
			changes += region_changes;
			if (region_changes)
				Pass::call(design, "opt_clean");
		}

		log("  PMUX_OPT made %d change(s).\n", changes);
	}
} PmuxOptPass;

PRIVATE_NAMESPACE_END
