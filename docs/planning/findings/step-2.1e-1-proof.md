# Step 2.1e part 1: the proof of the deploy's copy without `-t`

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

Run 2026-11-26 by Claude with the user's yes, for T23's "proven first". This was a one-off probe
script in the session's scratchpad, which is not kept. It ran against the deploy test's
throwaway server, built the way `tests/scenario/generic/dev-deploy-server.sh` builds it in
`dts-site-tools` at `18ef4c0`: Alpine 3.24.4, rsync 3.5.2-r1 and openssh 10.3_p1-r2 from
`tools/versions.sh`, one key forced into rsync's daemon mode, and the daemon settings of
`tests/tools/deploy/run.sh`. The client was this computer's rsync 3.2.7 (protocol 31); the
server ran rsync 3.5.2 (protocol 33). Nothing in either repository was changed, and the
container was removed afterwards.

## Situation

The server's folder held six things: a file with the same content as the source but an older
date; a file with different content and size; a file with the same size but different content;
a file the source does not have; an unchanged file; and a subfolder whose folder and file
differed only by date. The source also had a new file and a new subfolder with a file in it.
Every source file was dated at the time of the run, the way `git archive` dates every file with
its commit's time.

## Results (each passed)

- **A. The dry run and the real run list the same lines.** The planned options were
  `-r --delete --checksum --itemize-changes`, without `-t`. Both runs printed the same six
  lines, byte for byte:

  ```
  *deleting   to-delete.txt
  <fcsT...... changed-content.txt
  <f+++++++++ new-file.txt
  <fc.T...... same-size-changed.txt
  cd+++++++++ new-dir/
  <f+++++++++ new-dir/inner.txt
  ```

- **B. Without `-t`, nothing that differs only by date is listed or touched.** The file and the
  subfolder with only a date difference do not appear in either list. Their dates on the server
  were the same before and after the real copy. The same-size content change was caught by
  `--checksum`, so an edit made by hand on the server still shows up.
- **C. A second dry run after the real copy listed nothing.** The server's content then matched
  the source exactly (`diff -r`).
- **Control: today's options (`-rt`) list the date-only differences** (`.f..t......` for the
  file and the subfolder's file, `.d..t......` for the subfolder and the top folder). So the
  probe could see the fault behind the misleading counts of the `ea87e75` deploy.

## Notes for the build (part 2)

- Without `-t`, a copied file's line shows `T` in the time position. That means "the time will
  be set to the time of the copy", not that the file differs by date. Only files that are sent
  carry it.
- The probe's "unchanged file" was not quite unchanged. Its date was set in two time zones (the
  container's UTC and this computer's), so it differed by date and fell under B. A file that is
  the same in every way is a narrower case of B, so it is covered.
- Not proven here: Hostinger's own rsync version. Part 5 (the user's next real deploy) is where
  that gets confirmed.
