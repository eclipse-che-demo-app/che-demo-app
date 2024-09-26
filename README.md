# Quarkus & Angular Application Demo in Eclipse Che (OpenShift Dev Spaces)

This project was created as part of a demo for Eclipse Che: [OpenShift - Your New Favorite IDE](https://upstreamwithoutapaddle.com/blog%20post/2023/04/06/Development-On-OpenShift-With-Eclipse-Che.html)

This code repository contains the configuration for an OpenShift Dev Spaces (Eclipse Che) workspace that includes a three tier app.  The application is composed of an Angular frontend, a Quarkus backend, and a PostgreSQL database for persistence.

There are three main workspace components in this repo:

1. The Devfile - `./devfile`

   Defines the Eclipse Che / OpenShift Dev Spaces Workspace:

   Explained here: [Eclipse Che Devfile](./Devfile.md)

1. The VSCode workspace - `./che-demo.code-workspace`

   Explained here: [VSCode Workspace](CodeWorkspace.md)

1. The developer tooling image - `./images`

   Explained here: [Developer Tooling Image](Tooling.md)

The structure of this Github organization is an opinionated illustration of how an enterprise application team might choose to structure their project.
