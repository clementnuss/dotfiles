function kubectl-superpower 
    cat $HOME/.kube/config | yq eval '.users[0].user.as = .users[0].name' - | yq eval '.users[0].user.as-groups = ["system:masters"]' - > $HOME/.kube/config-sudo
    set -gx KUBECONFIG $HOME/.kube/config-sudo
end
