#cloud-config

manage_etc_hosts: true

apt_sources:
- source: "deb [arch=amd64] https://download.docker.com/linux/ubuntu ${ubuntu} stable"
  keyid: 9DC858229FC7DD38854AE2D88D81803C0EBFCD88

package_update: true
package_upgrade: true
package_reboot_if_required: true

packages:
- docker-ce
- docker-compose
- screen

runcmd:
- [ adduser, ${user}, docker ]
- curl https://krlmlr.github.io/azure-revdepcheck/bootstrap.sh | sh
