#!/usr/bin/env groovy

node {
  def govuk = load '/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy'
  govuk.buildProject(overrideTestTask: {
    stage("Lint") {
      sh "make lint"
    }

    stage("Test") {
      sh "make test"
    }
  })
}

