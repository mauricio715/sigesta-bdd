pipeline {
    agent any

    stages {
        stage('Clonar Repositorio') {
            steps {
                git branch: 'main', url: 'https://github.com/mauricio715/sigesta-bdd.git'
            }
        }
        stage('Ejecutar Pruebas E2E (Serenity BDD)') {
            steps {
                bat 'mvn clean verify'
            }
        }
    }

    post {
        always {
            publishHTML(target: [
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'target/site/serenity',
                reportFiles: 'index.html',
                reportName: 'Serenity Report SI-GESTA'
            ])
        }
    }
}