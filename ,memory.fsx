#!/usr/bin/env -S dotnet fsi
// -*- mode: fsharp -*-

open System.IO
open System.Text.RegularExpressions
open System
open System.Diagnostics
open System.Threading.Tasks

type CommandResult =
  { ExitCode: int
    StandardOutput: string
    StandardError: string }

let executeCommand executable args =
  async {
    let! ct = Async.CancellationToken

    let startInfo = ProcessStartInfo()
    startInfo.FileName <- executable
    startInfo.RedirectStandardOutput <- true
    startInfo.RedirectStandardError <- true
    startInfo.UseShellExecute <- false
    startInfo.CreateNoWindow <- true
    for a in args do
      startInfo.ArgumentList.Add(a)

    use p = new Process()
    p.StartInfo <- startInfo
    p.Start() |> ignore

    let outTask =
      Task.WhenAll([|
        p.StandardOutput.ReadToEndAsync(ct);
        p.StandardError.ReadToEndAsync(ct) |])

    do! p.WaitForExitAsync(ct) |> Async.AwaitTask
    let! out = outTask |> Async.AwaitTask

    return
      { ExitCode = p.ExitCode
        StandardOutput = out.[0]
        StandardError = out.[1] }
  }

let executeShellCommand command =
  executeCommand "/usr/bin/env" [ "-S"; "bash"; "-c"; command ]

let meminfo: seq<string> = File.ReadLines "/proc/meminfo"

let parseValue (name: string): float =
    let line = meminfo |> Seq.find(fun (line: string) -> line.StartsWith name)
    let maybe = Regex.Matches(line, "\d+") |> Seq.tryHead
    match maybe with
        | Some item -> float item.Value
        | None -> 0.0

let isLow () =
    let available = parseValue "MemAvailable"
    let total = parseValue "MemTotal"
    let used = (total - available) / total * 100.0
    Console.WriteLine used
    used > 90

let freeMemory () =
    [| "killall firefox"
       "pkill -f '[p]hpactor language-server'"
       "pgrep -x anydesk | xargs -r kill -9" |]
    |> Seq.iter (fun command -> executeShellCommand command |> Async.RunSynchronously |> ignore)

let force =
    fsi.CommandLineArgs
    |> Array.exists (fun arg -> arg = "-f" || arg = "--force")

if force || isLow() then
    freeMemory()
