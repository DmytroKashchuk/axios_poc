# Axios Compromise - Controlled Replication

This experiment reproduces the mechanics of the March 2026 axios npm
supply chain attack in an isolated VM. The payload is harmless: it
writes a marker file to `/tmp/pwned.txt`. The real attack dropped a
cross-platform RAT.

## Safety

- Run inside a fresh Ubuntu VM with NO network bridge to your host.
- Snapshot the VM before starting. Restore after.
- Do NOT use your real npm, GitHub, or cloud credentials in this VM.
- Do NOT publish anything to the public npm registry. We use Verdaccio
  (a local npm registry) so nothing leaves the VM.

## Architecture

```
[Verdaccio :4873]                 [my-app]
   axios@1.14.1 (modified)   <--- npm install axios
   plain-crypto-js@4.2.1               |
                                       v
                              postinstall hook fires
                                       |
                                       v
                              /tmp/pwned.txt (harmless marker)
```

`my-app` only declares `axios` as dependency. It never mentions
`plain-crypto-js`. The malicious package arrives transitively, and
its `postinstall` hook runs automatically on `npm install`.

## Files

| File                          | Purpose                                          |
|-------------------------------|--------------------------------------------------|
| `00-setup-vm.sh`              | Install Node.js, Verdaccio, Syft inside the VM   |
| `plain-crypto-js/`            | The malicious package (harmless payload)         |
| `01-prepare-evil-axios.sh`    | Download real axios 1.14.0, modify to 1.14.1     |
| `02-publish-to-verdaccio.sh`  | Publish both packages to local registry          |
| `my-app/`                     | The "victim" downstream application              |
| `03-run-experiment.sh`        | Run the three scenarios (A, B, C)                |

## Procedure

### Step 1 - prepare the VM

Inside a fresh Ubuntu 22.04+ VM:

```bash
chmod +x *.sh
./00-setup-vm.sh
```

### Step 2 - start Verdaccio

In one terminal:

```bash
verdaccio
```

Leave it running. It serves http://localhost:4873.

### Step 3 - configure npm to use Verdaccio

In another terminal:

```bash
npm set registry http://localhost:4873
npm adduser --registry http://localhost:4873
# enter a username/password/email, anything works
```

### Step 4 - prepare the evil axios

```bash
./01-prepare-evil-axios.sh
```

This downloads the real `axios@1.14.0` from the public npm registry
(once, while it is still allowed), bumps its version to `1.14.1`, and
adds `plain-crypto-js@4.2.1` to its dependencies. The axios source
code is NOT modified - this matches what the real attacker did.

### Step 5 - publish both packages to Verdaccio

```bash
./02-publish-to-verdaccio.sh
```

Now `plain-crypto-js@4.2.1` and `axios@1.14.1` exist in your local
registry. Verify at http://localhost:4873.

### Step 6 - run the experiment

```bash
./03-run-experiment.sh
```

You will see three scenarios:

- **Scenario A**: normal `npm install`. The postinstall hook fires.
  `/tmp/pwned.txt` appears. Compromise demonstrated.
- **Scenario B**: `npm install --ignore-scripts`. Same dependency
  tree, but the hook is blocked. No `/tmp/pwned.txt`.
- **Scenario C**: Syft generates an SBOM. `plain-crypto-js@4.2.1`
  shows up as a component, even though `my-app/package.json` never
  mentioned it.

## What this proves

1. A `postinstall` hook in a transitive dependency executes on
   `npm install`, even if the host application never imports the
   package.
2. The attacker did not need to modify the source code of axios.
   Adding one line to `package.json` was enough.
3. `npm install --ignore-scripts` blocks the entire class of attack.
   Most CI pipelines do not use it.
4. Tools like Syft expose the transitive dependency that
   `package.json` hides. This is a necessary first step for defense.

## Cleanup

```bash
rm -f /tmp/pwned.txt
cd my-app && rm -rf node_modules package-lock.json sbom.json
```

Then revert your VM to the pre-experiment snapshot.
