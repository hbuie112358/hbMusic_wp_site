# Step 2.1e, 0.3.1: the proof of rsync's plain-word list

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

Run 2026-11-26 by Claude with the user's yes, before building the deploy's single rsync list
(the user asked for one list of every file that changes, simple to read). This was a one-off
probe script in the session's scratchpad, which is not kept. It ran against the deploy test's
throwaway server, built the way `tests/scenario/generic/dev-deploy-server.sh` builds it in
`dts-site-tools` at `2d7492c` (`v0.3.0`): Alpine 3.24.4, rsync 3.5.2-r1 and openssh 10.3_p1-r2,
one key forced into rsync's daemon mode, and the daemon settings of `tests/tools/deploy/run.sh`
(a lock file and `incoming chmod` included; a first run without the lock file failed to connect
and proved nothing). The client was this computer's rsync 3.2.7 (protocol 31); the server ran
rsync 3.5.2 (protocol 33). Nothing in either repository was changed, and the container was removed
afterwards.

## Situation

The same as part 1 (`step-2.1e-1-proof.md`): a file with the same content but an older date; a
file with different content and size; one with the same size but different content; one the
source does not have; a subfolder whose folder and file differ only by date; and in the source, a
new file and a new subfolder with a file. Options: `-r --delete --checksum`, without `-t`.

## Results (each passed)

- **A. `--out-format='%o themes/example-child/%n'` prints the same lines in the dry run and the
  real run,** byte for byte, with the folder's path written into the format by rsync itself:

  ```
  del. themes/example-child/to-delete.txt
  send themes/example-child/changed-content.txt
  send themes/example-child/new-file.txt
  send themes/example-child/same-size-changed.txt
  send themes/example-child/new-dir/
  send themes/example-child/new-dir/inner.txt
  ```

- **B. Deletions are listed without `--itemize-changes`** (`del.`), so the list shows every
  removal as well as every file sent.
- **C. Nothing that differs only by date is listed,** and the same-size content change is still
  caught by `--checksum`.
- **D. A second dry run after the real copy listed nothing.**
- **The same with `%i` added** (`'%i %o …'`): identical in both runs, the itemized codes before
  the words.

## Notes for the build

- `send` covers both a new file and a changed one, and a new folder shows as `send <folder>/`.
  `%i` would tell new (`+++++++++`) from changed, at the cost of the codes the user found hard to
  read.
- Not proven here: Hostinger's own rsync. The user's next real deploy confirms it.
