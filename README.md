This branch contains the relevant files for creating, editing, and maintaining the Science Team visualization network for the Tri-State MNDK chapter of The Nature Conservancy. 

This folder contains the following files:
- ScienceTeamVis_v6.R: complete R code for creating the file. Uses a non-current working directory which should contain both the people_connections.csv and project_connections.csv files. When run, outputs a local .html file with the visualization network.
- employee_project_network_v6.html: html file which hosts the visualization
- index.html: support file for employee_project_network_v6.html
- people_connections.csv: file containing personelle names, position titles, job responsibilities, and projects. File is spread in wide format with project titles as columns to form a matrix. This file is used by both ScienceTeamVis_v6.R (locally) and employee_project_network_v6.html (on GitHub host site)
- project_connections.csv: file containing associations between projects and project themes. This file is used by both ScienceTeamVis_v6.R (locally) and employee_project_network_v6.html (on GitHub host site)
