provider "google" {
  credentials = "${file("${var.credentials}")}"
  project     = "${var.project}"
  region      = "${var.zone}"
}

resource "google_project_service" "project" {
  project = "${var.project}"
  service = "iam.googleapis.com"
}
