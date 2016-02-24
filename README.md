This is a tool for computing the individual and team results of a collegiate figure skating competition and publishing them to a website. This works by processing files in the `results` directory to generate `scores` files which contain a listing of all the points that each skater and team received. These `scores` files are further processed to generate `html` files that show the team results in a tabular format.

## OSX Usage
This only discusses blind usage, e.g., you're running a Collegiate Figure Skating competition and want to publish results to a website.

Open up a terminal. In OSX, you get to this by going to `Finder -> Applications -> Utilities -> Terminal`. This is just a way of interacting with your computer via text. Install homebrew (a way of downloading applications) with the following command. Copy and paste this into the terminal and hit enter on your keyboard:
```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

You may be prompted to enter your password for your computer. Note: when entering your password no characters (* or similar) will show in the terminal when you type.

Install `git` and `perl` using homebrew. You can do this with the following command after homebrew is installed. Note, that installing git will prompt you to install XCode. Allow OSX to do this:
```
brew install git perl
```

Login to [GitHub](https://github.com) or [create a GitHub account](https://github.com/join?source=header-home) if you don't have one. GitHub is a website for working on programming projects collaboratively and keeping track of changes through a versioning system called `git` (which you just installed).

Fork a copy of this repository (the project) by clicking "Fork" in the top right or using [this link](https://github.com/seldridge/ulysses#fork-destination-box). This creates a copy of the repository that you can then work on.

Then, grab a local copy of your forked version of this repository that will live on your computer. You will need to use your GitHub username, which I will indicate as `<USERNAME>`, and you will be prompted for your GitHub password:
```
cd ~
git clone https://www.github.com/<USERNAME>/ulysses
```

thatThis will place a copy of the forked repository on your computer in a directory called `<your username on your computer>/ulysses`. By default, when you open a terminal in OSX, you are automatically placed in the `<your username on your computer>` directory. From the terminal, you need to "change directory" (`cd`) into `ulysses`. Do that with:
```
cd ulysses
```

The way that `ulysses` works is that results are placed in a `results` directory. There exists one example results file: `2016_02_competition.results`. Create a copy (with the `cp` command) of this called `2016_03_competition.results` with the following command (you can copy and paste the command below):
```
cp results/2016_02_competition.results results/2016_03_competition.results
```

Now, you can edit `results/2016_03_competition.results` file. Open this with the built in OSX text editor: `Finder -> Applications -> TextEdit`. In TextEdit, open the file `<your username on your computer>/ulysses/results/2016_03_competition.results`. You can get to the `<your username on your computer>` directory by clicking in the drop down menu of the open file prompt.

You can then edit this file in TextEdit adding results. Make sure to remove the provided example results for an actual competition!

To determine the scores for this competition, in the open terminal type:
```
make
```

You should see the results appear on the screen. To publish these to a website, type:
```
make publish
```

This will then update a website at `https://<your github username>.github.io/ulsysses` like for my repo: [`https://seldridge.github.io/ulysses`](https://seldridge.github.io/ulysses).
