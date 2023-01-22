#!/bin/bash

# Check if CPU architecture is set
if [ -z "$CPU_ARCHITECTURE" ]
then
  echo "Error: Please include CPU architecture. Exiting..."
  exit 1
fi

# Enter server directory
cd mcserver

# Get lazymc
if [ "$LAZYMC_VERSION" = "latest" ]
then
  LAZYMC_VERSION=$(wget -qO - https://api.github.com/repos/timvisee/lazymc/releases/latest | jq -r .tag_name | cut -c 2-)
  if [ -z "$LAZYMC_VERSION" ]
  then
    echo "Error: Could not get latest version of lazymc. Exiting..."
    exit 1
  fi
fi
LAZYMC_URL="https://github.com/timvisee/lazymc/releases/download/v$LAZYMC_VERSION/lazymc-v$LAZYMC_VERSION-linux-$CPU_ARCHITECTURE"
status_code=$(curl -s -o /dev/null -w '%{http_code}' ${LAZYMC_URL})
if [ "$status_code" -ne 302 ]
then
  echo "Error: Lazymc version does not exist or is not available. Exiting..."
  exit 1
fi
wget -O lazymc ${LAZYMC_URL}
chmod +x lazymc

# Get version information and build download URL and jar name
case "$SERVER_PROVIDER" in
  "paper")
      URL=https://papermc.io/api/v2/projects/paper
      if [ ${MC_VERSION} = latest ]
      then
        # Get the latest MC version
        MC_VERSION=$(wget -qO - $URL | jq -r '.versions[-1]') # "-r" is needed because the output has quotes otherwise
        if [ $? -ne 0 ];
        then
          echo "Error: Could not get latest version of Minecraft"
          exit 1
        fi
      fi
      URL=${URL}/versions/${MC_VERSION}
      if [ ${SERVER_BUILD} = latest ]
      then
        # Get the latest build
        SERVER_BUILD=$(wget -qO - $URL | jq '.builds[-1]')
        if [ $? -ne 0 ];
        then
          echo "Error: Could not get latest build of Paper"
          exit 1
        fi
        else
        # Check if the build exists
        status_code=$(curl -s -o /dev/null -w '%{http_code}' ${URL}/builds/${SERVER_BUILD})
        if [ "$status_code" -ne 200 ]
        then
          echo "Error: Paper build does not exist or is not available. Exiting..."
          exit 1
        fi
      fi
      JAR_NAME=${SERVER_PROVIDER}-${MC_VERSION}-${SERVER_BUILD}.jar
      URL=${URL}/builds/${SERVER_BUILD}/downloads/${JAR_NAME}
      ;;
  "purpur")
      URL=https://api.purpurmc.org/v2/purpur/
      if [ ${MC_VERSION} = latest ]
      then
        # Get the latest MC version
        MC_VERSION=$(wget -qO - $URL | jq -r '.versions[-1]')
        if [ $? -ne 0 ];
        then
          echo "Error: Could not get latest version of Minecraft"
          exit 1
        fi
      fi
      BUILD_URL=https://api.purpurmc.org/v2/purpur/${MC_VERSION}/
      if [ ${SERVER_BUILD} = latest ]
      then
        # Get the latest build
        SERVER_BUILD=$(wget -qO - $BUILD_URL | jq -r '.builds.latest')
        if [ $? -ne 0 ];
        then
          echo "Error: Could not get latest build of Purpur"
          exit 1
        fi
        else
        # Check if the build exists
        status_code=$(curl -s -o /dev/null -w '%{http_code}' ${URL}builds/${SERVER_BUILD})
        if [ "$status_code" -ne 200 ]
        then
          echo "Error: Purpur build does not exist or is not available. Exiting..."
          exit 1
        fi
      fi

      JAR_NAME=${SERVER_PROVIDER}-${MC_VERSION}-${SERVER_BUILD}.jar
      URL=${BUILD_URL}${SERVER_BUILD}/download
      ;;
  *)
      echo "Error: Invalid SERVER_PROVIDER. Exiting..."
      exit 1
      ;;
esac

# Update if necessary
if [ ! -e ${JAR_NAME} ]
then
  # Remove old server jar(s)
  rm -f *.jar
  # Download new server jar
  if ! curl -f -o ${JAR_NAME} ${URL}
  then
      echo "Error: Jar URL does not exist or is not available. Exiting..."
      exit 1
  fi

  # If this is the first run, accept the EULA
  if [ ! -e eula.txt ]
  then
    # Run the server once to generate eula.txt
    java -jar ${JAR_NAME}
    # Edit eula.txt to accept the EULA
    sed -i 's/false/true/g' eula.txt
  fi
fi

# Add RAM options to Java options if necessary
if [ ! -z "${MC_RAM}" ]
then
  JAVA_OPTS="-Xms512M -Xmx${MC_RAM} ${JAVA_OPTS}"
else
  JAVA_OPTS="-Xms512M ${JAVA_OPTS}"
fi

# Generate lazymc.toml if necessary
if [ ! -e lazymc.toml ]
then
  ./lazymc config generate
  if [ $? -ne 0 ]; then
    echo "Error: Could not generate lazymc config"
    exit 1
  fi
else
  # Add new values to lazymc.toml
  echo "Updating lazymc.toml with latest details"
  # Check if the comment is already present in the file
  if ! grep -q "mcserver-lazymc-docker" lazymc.toml;
  then
    # Add the comment to the file
    sed -i '/Command to start the server/i # Managed by mcserver-lazymc-docker, please do not edit this!' lazymc.toml
  fi
  sed -i "s~command = .*~command = \"java $JAVA_OPTS -jar $JAR_NAME nogui\"~" lazymc.toml
fi



# Start the server
./lazymc start
if [ $? -ne 0 ]; then
    echo "Error: Could not start the server"
    exit 1
fi