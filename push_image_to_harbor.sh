#!/usr/bin/env sh

push_image_to_harbor () (
  # REPOSITORY             TAG
  # localhost/rest-manager:1.0.0
  image=${1##*/}

  # login to harbor
  control_pane=cp-657030 # display name: cp-657030 - IB Processing Platform Test
  control_pane=cp-666093 # display name: cp-657030 - IB Processing Platform Dev
  harbor_host=harbor.emea.ocp.int.kn
  harbor_user=$(vault read --field user "processing/harbor/prod/${harbor_host}/${control_pane}/robot_accounts/ibpp-harbor")
  vault read --field password processing/harbor/prod/${harbor_host}/${control_pane}/robot_accounts/ibpp-harbor | \
  podman login --username "${harbor_user}" --password-stdin ${harbor_host}

  # tag image
  # REPOSITORY                                     TAG
  # harbor.emea.ocp.int.kn/cp-657030/rest-manager  1.0.0
  custom_image=${harbor_host}/${control_pane}/${image}
  podman tag "${image}" "${custom_image}"

  # push image (no destination specified; destination taken from custom image tag)
  podman push "${custom_image}"
)


#REPOSITORY                                     TAG         IMAGE ID      CREATED      SIZE
#harbor.emea.ocp.int.kn/cp-657030/rest-manager  1.0.0       07c065c3bad0  3 hours ago  1.28 GB
#localhost/rest-manager                         1.0.0       07c065c3bad0  3 hours ago  1.28 GB
