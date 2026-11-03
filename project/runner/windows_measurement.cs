using System;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

// External Windows resource measurement; no changes to Yosys or ABC.
public sealed class PmuxWindowsMeasurement : IDisposable
{
    [StructLayout(LayoutKind.Sequential)]
    private struct MemoryCounters
    {
        public uint cb, PageFaultCount;
        public UIntPtr PeakWorkingSetSize, WorkingSetSize;
        public UIntPtr QuotaPeakPagedPoolUsage, QuotaPagedPoolUsage;
        public UIntPtr QuotaPeakNonPagedPoolUsage, QuotaNonPagedPoolUsage;
        public UIntPtr PagefileUsage, PeakPagefileUsage;
    }

    [DllImport("psapi.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool GetProcessMemoryInfo(
        IntPtr process, out MemoryCounters counters, uint size);

    private readonly Process process = new Process();
    private readonly FileStream stdout, stderr;
    private Task stdoutCopy, stderrCopy;
    private IntPtr handle;
    private bool started;

    // Windows CRT argument quoting, including embedded quotes and backslashes.
    private static string Quote(string value)
    {
        StringBuilder text = new StringBuilder("\"");
        int slashes = 0;
        foreach (char c in value)
        {
            if (c == '\\') { slashes++; continue; }
            if (c == '"')
            {
                text.Append('\\', slashes * 2 + 1);
                text.Append(c);
            }
            else { text.Append('\\', slashes); text.Append(c); }
            slashes = 0;
        }
        text.Append('\\', slashes * 2);
        return text.Append('"').ToString();
    }

    public PmuxWindowsMeasurement(string executable, string script, string yosysLog,
        string stdoutLog, string stderrLog, string workingDirectory, string runtimePath)
    {
        process.StartInfo = new ProcessStartInfo {
            FileName = executable,
            Arguments = "-Q -d -l " + Quote(yosysLog) + " -s " + Quote(script),
            WorkingDirectory = workingDirectory,
            UseShellExecute = false,
            CreateNoWindow = true,
            RedirectStandardOutput = true,
            RedirectStandardError = true
        };
        if (!String.IsNullOrWhiteSpace(runtimePath))
            process.StartInfo.EnvironmentVariables["PATH"] = runtimePath + ";" +
                process.StartInfo.EnvironmentVariables["PATH"];
        string nativeTcl = Environment.GetEnvironmentVariable("PMUX_SYNTH_TCL_LIBRARY");
        if (!String.IsNullOrWhiteSpace(nativeTcl))
            process.StartInfo.EnvironmentVariables["TCL_LIBRARY"] = nativeTcl;
        stdout = new FileStream(stdoutLog, FileMode.Create, FileAccess.Write, FileShare.Read);
        stderr = new FileStream(stderrLog, FileMode.Create, FileAccess.Write, FileShare.Read);
    }

    public void Start()
    {
        if (!process.Start()) throw new InvalidOperationException("Yosys did not start.");
        started = true;
        // Retain the process handle before waiting, including for short cases.
        handle = process.Handle;
        stdoutCopy = process.StandardOutput.BaseStream.CopyToAsync(stdout);
        stderrCopy = process.StandardError.BaseStream.CopyToAsync(stderr);
    }

    public void Wait() { process.WaitForExit(); }
    public int ExitCode { get { return process.ExitCode; } }

    public ulong ReadPeakWorkingSet()
    {
        MemoryCounters counters;
        if (!GetProcessMemoryInfo(handle, out counters,
                (uint)Marshal.SizeOf(typeof(MemoryCounters))))
            throw new Win32Exception(Marshal.GetLastWin32Error(),
                "Cannot read the Yosys peak working set from the retained process handle.");
        ulong peak = counters.PeakWorkingSetSize.ToUInt64();
        if (peak == 0) throw new InvalidOperationException("Windows returned a zero peak working set.");
        return peak;
    }

    public void FinishLogs()
    {
        Task.WaitAll(stdoutCopy, stderrCopy);
        stdout.Flush();
        stderr.Flush();
    }

    public void Dispose()
    {
        if (started && !process.HasExited)
        {
            try { process.Kill(); process.WaitForExit(); } catch (InvalidOperationException) { }
        }
        try { if (stdoutCopy != null && stderrCopy != null) Task.WaitAll(stdoutCopy, stderrCopy); }
        finally { stdout.Dispose(); stderr.Dispose(); process.Dispose(); }
    }
}
