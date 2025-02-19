################################################################################
### title: "MNDK Science Team Project/Theme Network"
### author: "Maggie Anderson"
### organization: The Nature Conservancy, MNDK Tri-State Chapter
### date: "2025-02-05"

### description:
#   Source code for MNDK Science Team Project/Theme Network visNetwork diagram
#   found at: https://maggie-anderson-tnc.github.io/TNC_MNDK_ScienceTeamVis/
################################################################################

rm(list=ls()) 

# Assuming final_df is your data frame
library(visNetwork)

# Generate project names
projects <- c("Resilience Forestry", "Renewing Forests with Fire", "NCS Mitigation and Carbon Projects", 
              "Forest Protection", "Grassland and Wetland Reconstruction", "Grassland and Wetland Protection","Resilient Grassland and Wetland Management",
              "Supporting Regenerative Grazing Lands", "Connecting People to Nature", "Sustainable Aviation Fuel", 
              "Stream and Riparian Restoration", "River Reconnection", "Water and Shoreline Protection", 
              "Wetland and Peatland Restoration", "Wild Rice Conservation", "Research Permits", "Metrics", "Science Communication", 
              "Data Management & Geospatial Support", "Public Funding Support", "Sustainability", "Conservation Planning Support", "Climate Adaptation Planning")

# Assign themes to projects
themes <- c("Forests", "Grasslands", "Freshwater", "General Science")

# Create a data frame for projects and themes
setwd("C:/Users/maggie.anderson/Box/R_projects/Misc/ScienceTeamVis/ScienceTeamVis_CurrentVersion")
people_connections <- read.csv("people_connections.csv")
project_connections <- read.csv("project_connections.csv")

# Assign theme colors
theme_colors <- c("Forests" = "#006400", "Grasslands" = "#B8860B", "Freshwater" = "#136879", "General Science" = "#380a0a")

# Assign project colors
project_colors <- c("Resilience Forestry"="#409e40", "Renewing Forests with Fire"="#68c668", "NCS Mitigation and Carbon Projects"="#90ee90", 
                    "Forest Protection"="#b8ffb8", "Grassland and Wetland Reconstruction"= "#ffdb83", "Grassland and Wetland Protection"="#f1df61","Resilient Grassland and Wetland Management"="#efe78a",
                    "Supporting Regenerative Grazing Lands"= "#f0df6b", "Connecting People to Nature"= "#eee3aa", "Sustainable Aviation Fuel"= "#f7d293", 
                    "Stream and Riparian Restoration"="#85b0be", "River Reconnection"="#add8e6", "Water and Shoreline Protection"= "#d5ffff", 
                    "Wetland and Peatland Restoration" = "#87CEEB", "Wild Rice Conservation"= "#b4d3d3", "Research Permits" = "#e79c9c", "Metrics"="#e79f9c", "Science Communication"="#e7a29b", 
                    "Data Management & Geospatial Support"="#e7a59b", "Public Funding Support"="#e7a99c", "Sustainability"="#e7ac9c", "Conservation Planning Support"="#e6af9d", "Climate Adaptation Planning"="#e6b29e")

projects_df <- project_connections %>%
  rename(Theme = Category,
         Project = Position) %>%
  mutate(Theme_Color = theme_colors[Theme],
         Project_Color = project_colors[Project])

# Convert to long format
df_long <- people_connections %>%
  pivot_longer(cols = -c(Name, Position, Job.Responsibilities), names_to = "Project", values_to = "Value") %>%
  filter(Value == "X") %>%
  dplyr::select(-Value)

# Replace periods with spaces in the "Project" column
df_long$Project <- gsub("\\.", " ", df_long$Project)

# Rename columns
employee_projects <- df_long %>%
  rename(Employee = Name) %>%
  group_by(Employee) %>%
  ungroup()

# Merge project themes and colors with employee projects
final_df <- merge(employee_projects, projects_df, by = "Project")

# Extract unique themes, projects, and employees
themes <- unique(final_df$Theme)
projects <- unique(final_df$Project)
employees <- unique(final_df$Employee)

# Create nodes data frame
theme_nodes <- data.frame(id = 1:length(themes), label = themes, level = 1, color = theme_colors[themes], font.color = "white", font.size = 40, size = 60, title = "") #, physics = FALSE
project_nodes <- data.frame(id = (length(themes) + 1):(length(themes) + length(projects)), label = projects, level = 2, color = project_colors[projects], font.color = "black", font.size = 20, size = 40, title = "")

employee_nodes <- data.frame(id = (length(themes) + length(projects) + 1):(length(themes) + length(projects) + length(employees)), 
                             label = employees, 
                             level = 3, 
                             color = "#000000", 
                             font.color = "white", 
                             font.size = 15, 
                             size = 30,
                             title = paste("Position:", people_connections$Position[match(employees, people_connections$Name)], 
                                           "<br>Job Responsibilities:", people_connections$Job.Responsibilities[match(employees, people_connections$Name)]))

nodes <- rbind(theme_nodes, project_nodes, employee_nodes)

# Create edges data frame
edges <- data.frame(from = integer(), to = integer())

# Add edges from themes to projects with alternating lengths
for (i in seq_along(themes)) {
  theme_id <- theme_nodes$id[theme_nodes$label == themes[i]]
  project_ids <- project_nodes$id[project_nodes$label %in% final_df$Project[final_df$Theme == themes[i]]]
  for (j in seq_along(project_ids)) {
    length <- ifelse(j %% 2 == 0, 200, 400)  # Alternate between 200 and 400
    edges <- rbind(edges, data.frame(from = theme_id, to = project_ids[j], length = length))
  }
}

# Add edges from projects to employees
for (project in projects) {
  project_id <- project_nodes$id[project_nodes$label == project]
  employee_ids <- employee_nodes$id[employee_nodes$label %in% final_df$Employee[final_df$Project == project]]
  for (employee_id in employee_ids) {
    edges <- rbind(edges, data.frame(from = project_id, to = employee_id, length = NA))  # No specific length for these edges
  }
}

# Visualize the network
hmm <- visNetwork(nodes, edges, width = "100%", height = "1200px",
                  main = "MNDK Science Team Project/Theme Network",
                  submain = "Click on the themes, projects, and people in the diagram below to understand how our team functions. Hover over our team members to learn what we do.") %>%
  visNodes(shape = "box", font = list(align = "center", rotate = 90, color = list(highlight = "black", hover = "black", unhighlight = "rgba(200,200,200,0.5)"))) %>%
  visEdges(arrows = "to") %>%
  visInteraction(navigationButtons = TRUE) %>%
  visHierarchicalLayout(levelSeparation = 400, direction = "LR") %>%
  visOptions(highlightNearest = list(enabled = TRUE, degree = list(from = 3, to = 3), hover = TRUE, algorithm = "hierarchical", hideColor = "rgba(200,200,200,0.5)", labelOnly = FALSE), 
             nodesIdSelection = list(enabled = TRUE, useLabels = TRUE))

# Save the network plot as an HTML file
setwd("C:/Users/maggie.anderson/Box/R_projects/Misc/ScienceTeamVis/ScienceTeamVis_CurrentVersion") # working directory on my PC
visSave(hmm, file = "employee_project_network_v6.html")
