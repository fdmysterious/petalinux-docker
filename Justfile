image_name := "petalinux:2024.1"

# Check that the given environment variable is defined
env-check-var var:
   @{{ if env_var_or_default(var, "") == "" {"echo 'Please define the " + var + " environment variable' && exit 1"} else {""} }}


# Ensure the requested environment variables are defined
env-ensure:
   @just env-check-var "DL_DIR"
   @just env-check-var "SSTATE_DIR"


# Build the docker image
image-build:
   docker buildx build -t {{image_name}} --load docker

# Check that the docker image exists
image-check:
   docker images --format='1' -f reference="{{image_name}}"

# Ensure the docker image has been built before proceeding
image-ensure:
   {{ if `just image-check` != '1' {"just image-build"} else {""} }}

shell: env-ensure image-ensure
   docker run --rm -it -v ./project:/project -v ./bsp:/bsp -v {{env_var('SSTATE_DIR')}}:/home/petalinux/cache/sstate-cache -v {{env_var('DL_DIR')}}:/home/petalinux/cache/downloads {{image_name}} bash