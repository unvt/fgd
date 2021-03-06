# fgd
A tool in the UN Vector Tile Toolkit (UNVT) to produce vector tiles from Japanese Fundamental Geospatial Data (FGD)

# install
## Install UNVT on your Raspberry Pi
https://github.com/unvt/equinox

## Install Software
```zsh
git clone git@github.com/unvt/fgd
cd fgd
yarn
sudo gem install rubyzip
```

# Download the data
https://fgd.gsi.go.jp/download

Our default is that you have your FGD data on ~/Downloads/PackDLMap. You can change this setting by editing Rakefile.

# use
```zsh
rake produce
vi Rakefile # modify LAN_URL / GITHUB_URL if necessary
rake lan
rake host
# check http://localhost on your browser
rake pages
cp docs ~/your-pages-repo
```

