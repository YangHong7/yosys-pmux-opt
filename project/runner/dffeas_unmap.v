// Formal inverse of Yosys 0.69 intel/common/ff_map.v, NOT a black box.
// Only the exact control configuration emitted by that map is supported.
// Unexpected controls deliberately leave dffeas unmapped and fail the check.
(* techmap_celltype = "dffeas" *)
module dffeas_unmap (
    input d, clk, clrn, prn, ena, asdata, aload, sclr, sload,
    output reg q
);
    parameter power_up = "dontcare";
    parameter is_wysiwyg = "false";
    parameter _TECHMAP_CONSTMSK_prn_ = 0;
    parameter _TECHMAP_CONSTVAL_prn_ = 0;
    parameter _TECHMAP_CONSTMSK_asdata_ = 0;
    parameter _TECHMAP_CONSTVAL_asdata_ = 0;
    parameter _TECHMAP_CONSTMSK_aload_ = 0;
    parameter _TECHMAP_CONSTVAL_aload_ = 0;
    parameter _TECHMAP_CONSTMSK_sclr_ = 0;
    parameter _TECHMAP_CONSTVAL_sclr_ = 0;
    parameter _TECHMAP_CONSTMSK_sload_ = 0;
    parameter _TECHMAP_CONSTVAL_sload_ = 0;
    wire _TECHMAP_FAIL_ =
        !_TECHMAP_CONSTMSK_prn_ || !_TECHMAP_CONSTVAL_prn_ ||
        !_TECHMAP_CONSTMSK_asdata_ || _TECHMAP_CONSTVAL_asdata_ ||
        !_TECHMAP_CONSTMSK_aload_ || _TECHMAP_CONSTVAL_aload_ ||
        !_TECHMAP_CONSTMSK_sclr_ || _TECHMAP_CONSTVAL_sclr_ ||
        !_TECHMAP_CONSTMSK_sload_ || _TECHMAP_CONSTVAL_sload_;
    generate
        if (power_up == "low") initial q = 1'b0;
        else if (power_up == "high") initial q = 1'b1;
    endgenerate
    always @(posedge clk or negedge clrn)
        if (!clrn) q <= 1'b0;
        else if (ena) q <= d;
endmodule
