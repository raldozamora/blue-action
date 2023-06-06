FROM node:18

# install tools
# - jq: needed by script to parse json
# - wget: download files
ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8
RUN apt-get update
RUN apt-get install --no-install-recommends -y jq wget

# folder for working files
RUN mkdir -p /action_work_folder

# Prepare entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
