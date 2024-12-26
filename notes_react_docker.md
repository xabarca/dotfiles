## References

 - https://willschenk.com/articles/2020/developing_react_inside_docker/
 - https://www.pluralsight.com/guides/using-react.js-with-docker


## create-react-app using temp image/container

 - go to a folder in where we want to create our project (in this case called myapp)
 - create a file called 'Dockerfile.initial' on it


Dockerfile.initial
```
FROM node:alpine
WORKDIR /app
CMD bash
```

 - docker build . -f Dockerfile.initial -t tempimage
 - docker run -it --rm -v ${PWD}/myapp:/app  tempimage npx create-react-app .
 - docker image rm tempimage
 - sudo chown -R $USER:$USER myapp 
 

## Setting up for development

 - create a file called 'Dockerfile' at the root of your project
 - create a '.dockerignore' file there too
 - create a 'go.sh' file to be able to interact as a helper with the container once it will be created


Dockerfile
```
# pull the base image
FROM node:alpine

# set the working direction
WORKDIR /app

# add `/app/node_modules/.bin` to $PATH
ENV PATH /app/node_modules/.bin:$PATH

# ensure permissions
RUN chown -Rh node:node /app

# install app dependencies
COPY package.json ./

COPY package-lock.json ./

RUN npm install 

# add app
COPY . ./

# start app
#CMD ["npm", "start"]
CMD bash
```

.dockerignore
```
node_modules
npm-debug.log
build
.dockerignore
**/.git
**/.DS_Store
**/node_modules
```

go.sh
```
#!/usr/bin/env bash

docker build . -f Dockerfile -t react-node:dev && \
docker run -it --rm -v ${PWD}:/app --network host -p 3001:3000 react-node:dev $@
```
 
 - execute 'go.sh' helper to interact with the container npm:  
    * bash go.sh npm start
    * bash go.sh npm install react-router-dom
    * bash go.sh npm run build
    * etc....

 
