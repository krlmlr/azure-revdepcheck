set -e

rm -rf azure-revdepcheck
git clone https://github.com/krlmlr/azure-revdepcheck.git

cd azure-revdepcheck/provision
docker-compose up --build -d
