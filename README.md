## Manuscript title: Gender Criteria Gap in Evaluation: Role of Perceived Intentions and Outcomes
**Author(s): Nisvan Erkal, Lata Gangadharan, Boon Han Koh**

---

### 1. Overview

This document provides information on the files available in the replication package.

There are 3 main folders:

(1) `ZTREE` contains the z-Tree software used to conduct the experiment.

(2) `STATA` contains all the necessary STATA codes and datasets to replicate tables, figures, and in-text tests reported in both the main text of the paper and the online appendix.

---

### 2. Data availability and provenance

This paper relies on data, and all data necessary to reproduce the results of the paper are included. Below is a detailed description of how the data was obtained, allowing to reproduce the dataset.

The dataset used in the paper is generated via in-person laboratory experiments using z-Tree (version `4.1.11`). Online Appendix A contains the instructions and protocols used in the experiment.

---

### 3. Variable dictionaries

The STATA folder contain DO files which label the variable names and values, including providing informative descriptions of the core variables that are used in the analysis. As such, the user can open the corresponding cleaned `.dta` files and use the command `desc` to obtain the variable dictionaries.

---

### 4. Computational requirements

z-Tree version `4.1.11` is used to run the z-Tree software.

STATA 19 is used for all codes contained in the STATA folder. Additional packages need to be installed in order to run the `esttab`, `addplot`, and `addplot` commands. Use `ssc install …` to install these packages.

---

### 5. Programs/Code

#### a. z-Tree

The code should be saved in a separate folder and run using z-Tree version `4.1.11`. The program needs to be run with multiples of 6 clients.

#### b. STATA

All necessary DO files are contained in the `2-doFiles` folder. The `1-RawData` folder contains all raw datasets that have been merged, with identifying information removed.

The cleaning DO file is `cl-main.do`, which converts the raw dataset to a cleaned dataset, saved in the `Data` folder for analysis (the folder will be created if it does not yet exist).

After running the cleaning file, the cleaned datasets are used by the analysis files (all labelled `an-`) to generate the figures, tables, and in-text test statistics reported in both the main text and the online appendix.

In all the DO files, the user will need to change the directory accordingly in the following line at the beginning of the file:

`local path "..."`

Replace `...` with the full local path to the project folder. All DO files rely on this path.

The analysis DO files will generate figures, tables, and log files in the respective folders (which will be created if not yet already there).

