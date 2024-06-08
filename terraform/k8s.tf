data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.eks_cluster_name

}

provider "kubernetes" {
  host                   = module.eks.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.eks_cluster_certificate_authority_data[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

resource "kubernetes_deployment" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = kubernetes_namespace.jenkins.metadata.0.name
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "jenkins"
      }
    }

    template {
      metadata {
        labels = {
          app = "jenkins"
        }
      }

      spec {
        container {
          name  = "jenkins"
          image = "jenkins/jenkins" 
        }
        }
      }
    }
  }

resource "kubernetes_service" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = kubernetes_namespace.jenkins.metadata.0.name
  }
  spec {
    selector = {
      app = "jenkins"
    }

    port {
      port        = 8080
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_service_account" "jenkins_master" {
  metadata {
    name      = "jenkins-master"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }
  # Your service account configuration here
}

resource "kubernetes_service_account" "jenkins_slave" {
  metadata {
    name      = "jenkins-slave"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }
  # Your service account configuration here
}

resource "kubernetes_cluster_role" "jenkins_cluster_role" {
  metadata {
    name = "jenkins-cluster-role"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "pods/exec", "services", "deployments", "statefulsets", "configmaps", "secrets", "ingresses"]
    verbs      = ["get", "list", "create", "delete", "update", "patch", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "jenkins_master_cluster_role_binding" {
  metadata {
    name = "jenkins-master-cluster-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.jenkins_cluster_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jenkins_master.metadata[0].name
    namespace = kubernetes_service_account.jenkins_master.metadata[0].namespace
  }
}

resource "kubernetes_cluster_role_binding" "jenkins_slave_cluster_role_binding" {
  metadata {
    name = "jenkins-slave-cluster-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.jenkins_cluster_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jenkins_slave.metadata[0].name
    namespace = kubernetes_service_account.jenkins_slave.metadata[0].namespace
  }
}
