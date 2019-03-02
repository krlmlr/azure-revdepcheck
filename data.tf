data "template_file" "init" {
  template = "${file("init.tpl")}"

  vars {
    ubuntu = "bionic"
  }
}

data "template_cloudinit_config" "config" {
  gzip = false
  base64_encode = false

  part {
    filename = "init.cfg"
    content_type = "text/cloud-config"
    content = "${data.template_file.init.rendered}"
  }
}
