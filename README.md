# Xonotic - Flatpak Builder manifest

This is a very early proof of concept for building Xonotic within a Flatpak environment. This is not recommended for use. It will create a large less-optimised package compared to the official build server.

## Prerequisites

```bash
flatpak install flathub org.freedesktop.Sdk//1.6
flatpak install flathub org.freedesktop.Platform//1.6
```

## Build and install

Clone the repository and from within it run:
```bash
flatpak-builder --user --install --disable-updates --force-clean xonotic org.xonotic.Xonotic.json
```

## Updating and building from different commits
Xonotic's build system pulls down pre-built versions of maps (bsp) from the official build server. Within a flatpak-builder environment app build systems are discouraged (and by default blocked) from doing this and should instead let flatpak-builder source the needed files instead (safer for app store build environments). Thus the manifest needs to know what files to get. When changing the commit version of Xonotic to build, matching pk3 files must be used.  The pk3 sources list can be automatically generated using the included `build-map-sources-manifest.sh` script. Thus checkout the **xonotic-maps.pk3dir** version matching the commit hash in the manifest for that source:
```bash
git clone git.xonotic.org/xonotic/xonotic-maps.pk3dir.git
cd xonotic-maps.pk3dir
git checkout [COMMITHASH]
```
Copy `build-map-sources-manifest.sh` to the checkout of xonotic-maps.pk3dir and execute it:
```bash
cp PATH/TO/THIS/LOCAL-REPO-DIR/build-map-sources-manifest.sh .
bash build-map-sources-manifest.sh
```
That will generate a new **xonotic-pk3.sources.json** file. Copy that over the one in this repo and follow the instructions in *Build and install*. Flatpak Builder will then download the correct pk3 files and proceed to build Xonotic into a flatpak package.
