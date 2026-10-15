tar -xzf axios-replication.tar.gz
cd axios-replication
chmod +x *.sh

./00-setup-vm.sh                     # installa Node.js, Verdaccio, Syft

verdaccio &                          # in background (o terminale separato)
npm set registry http://localhost:4873
npm adduser --registry http://localhost:4873

./01-prepare-evil-axios.sh           # scarica axios reale, lo modifica
./02-publish-to-verdaccio.sh         # pubblica entrambi i pacchetti localmente
./03-run-experiment.sh               # esegue i 3 scenari
