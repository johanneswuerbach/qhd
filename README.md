# qhd - Quick Humanitec Demo

Your Humanitec Demo Environment in less than 3 minutes.

Required:

* [humctl](https://developer.humanitec.com/platform-orchestrator/cli/)
* docker

## Usage

### Configure

```bash
humctl login
export HUMANITEC_ORG=MY_ORG
```

### Run

* Start the toolbox

  ```bash
  docker run --rm -it -h=qhd --pull=always \
    -v $(PWD):/app \
    -v $HOME/.humctl:/root/.humctl \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e HUMANITEC_ORG \
    ghcr.io/johanneswuerbach/qhd
  ```

* Use it!

  ```bash
  ./0_install.sh # install & connect a local cluster powered by kind
  ./1_demo.sh # deploy your 1st score workload
  ./2_cleanup.sh # cleanup everything
  ```
