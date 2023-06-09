library(tidyr)
library(dplyr)
library(ggplot2)
library(plotly)
library(forcats)
library(gridExtra)
library(circlize)
library(stringr)

games <- read.csv("C:\\Users\\Komputer\\interactive-dashboard\\steam-games-dataset\\clustered_games.csv")
games <- read.csv("steam-games-dataset/clustered_games.csv")
games$X.1<-NULL
games$X<-NULL
chosen_game="Terraria"

cluster_value <- games %>% filter(QueryName == chosen_game) %>% pull(cluster)
similar_games <- games %>% filter(cluster == cluster_value)
game_number<-which(similar_games$QueryName == chosen_game)
similar_games <- similar_games %>% filter(QueryName != chosen_game)

###################Density Plot for Meta critic scores##########################

# Change it to colors corresponding to game scores
game_score <- games %>%
  filter(QueryName == chosen_game) %>%
  pull(Metacritic)

ggplot(similar_games, aes(x = Metacritic)) +
  stat_density(geom = "line", color = "black", size = 1) +
  stat_density(geom = "area", alpha = .3, fill = "black") +
  scale_fill_gradient2(low = "red", mid = "yellow", high = "green", midpoint = 70) +
  scale_color_gradient2(low = "red", mid = "yellow", high = "green", midpoint = 70) +
  labs(title = "Distribution of Metascores for Recommended Games", x = "Metascore",
       y = "Density") + 
  geom_vline(aes(xintercept = game_score), color = "red") +
  annotate("text", x=game_score+5, y=0.022, label=chosen_game, angle=90,
           hjust=-0.2, size=4) +
  xlim(0,100)




###### 
title_size <- 20
label_size <- 16
tick_size <- 12
grid_size <- 0.5

# Gradient
score_density <- density(games$Metacritic, n = 2^12, kernel="gaussian", bw="nrd0", window = "gaussian")
similar_scores_density <- data.frame(x=score_density$x, y=score_density$y)
similar_scores_density %>% ggplot(aes(x, y)) + 
  geom_line() + 
  geom_segment(aes(xend=x, yend=0, colour=x)) + # alpha=0.2
  scale_color_gradient2(low = "#FF0000", mid="#FFCC33", high = "#66CC33", midpoint=60) +
  ggtitle("Density distribution of metacritic scores of similar games") + 
  geom_vline(aes(xintercept = game_score), color = "white", size=1) +
  annotate("text", x=game_score+5, y=0.022, label=chosen_game, angle=90, color="white", hjust=0, size=4) +
  xlim(0,100) +
  labs(x = "Metacritic score", color = "Score") +
  theme(plot.background = element_rect(fill="#2c323b"),
        plot.title=element_text(size=title_size, colour = "white", hjust=0.4),
        axis.title.x = element_text(size=label_size, colour = "white"),
        axis.title.y = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        panel.background = element_rect(fill="#2c323b"),
        legend.background = element_rect(fill="#2c323b"),
        legend.text = element_text(size=tick_size, color ="white"),
        legend.title = element_text(size=label_size, color = "white"),
        legend.key = element_rect(fill="#2c323b"))

score_density <- density(games$Metacritic, n = 2^12, kernel="gaussian", bw="nrd0", window = "gaussian")
similar_scores_density <- data.frame(x=score_density$x, y=score_density$y)

# Breaks
similar_scores_density %>% ggplot(aes(x, y)) + 
  geom_line(color="white") + 
  geom_segment(aes(xend=x, yend=0, colour=x)) + # alpha=0.2
  scale_color_stepsn(colors=c(
    "#FF0000", 
    "#FFCC33", 
    "#66CC33"), 
    breaks=c(50, 75))  +
  ggtitle("Density distribution of metacritic scores of similar games") + 
  geom_vline(aes(xintercept = game_score), color = "white", size=1) +
  annotate("text", x=game_score+5, y=0.022, label=chosen_game, angle=90, color="white", hjust=0, size=4) +
  xlim(0,100) +
  labs(x = "Metacritic score", color = "Score") +
  theme(plot.background = element_rect(fill="#2c323b"),
        plot.title=element_text(size=title_size, colour = "white", hjust=0.4),
        axis.title.x = element_text(size=label_size, colour = "white"),
        axis.title.y = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        panel.background = element_rect(fill="#2c323b"),
        legend.background = element_rect(fill="#2c323b"),
        legend.text = element_text(size=tick_size, color ="white"),
        legend.title = element_text(size=label_size, color = "white"),
        legend.key = element_rect(fill="#2c323b"))


#################Bar plot for distribution of genres############################

chosen_game <- "Team Fortress 2"
genre_counts <- similar_games %>%
  mutate(across(starts_with("Genre"), ~ .x == "True")) %>%
  summarise(across(starts_with("Genre"), ~ sum(.x))) %>%
  pivot_longer(everything(), names_to = "Genre", values_to = "Count")

temp_data <-similar_games %>% select(starts_with("Genre")) %>% slice(game_number)
temp_data <- temp_data %>% mutate(across(everything(), ~ ifelse(.x, "green", "grey")))
temp_data <- temp_data %>% gather(key = "Genre", value = "Color")
genre_counts <- left_join(genre_counts, temp_data, by="Genre")

genre_counts <- genre_counts %>%
  filter(Genre != "GenreIsAll")

genre_counts <- genre_counts %>%
  arrange(desc(Count))

genre_counts$Genre <- lapply(genre_counts$Genre, function(x) substring(x, 8,20)) 

genre_counts %>%
  mutate(Genre=fct_reorder(as.character(Genre), Count)) %>%
  ggplot(aes(x = Count, y = Genre, fill=Color)) +
  geom_col() +
  labs(title = "Histogram of Genre Counts", x = "Genre", y = "Count")

#############################How old to play plot ##############################
age_counts<-similar_games %>% count(RequiredAge)

age_counts$RequiredAge <- factor(age_counts$RequiredAge)

p1<-ggplot(age_counts, aes(x = RequiredAge, y = n)) +
  geom_col() +
  labs(x = "Age", y = "Number of Games") +
  theme_minimal() + ggtitle("Distribution of Required Age for Similar Games")

age_counts_2<-games %>% count(RequiredAge)

age_counts_2$RequiredAge <- factor(age_counts_2$RequiredAge)

p2<-ggplot(age_counts_2, aes(x = RequiredAge, y = n)) +
  geom_col() +
  labs(x = "Age", y = "Number of Games") +
  theme_minimal() + ggtitle("Distribution of Required Age for all Games")

grid.arrange(p1, p2, ncol = 1)


################################Network diagram#################################
# Create a co-occurrence matrix
#devtools::install_github("mattflor/chorddiag")
library(chorddiag)

# Load the data
game_genres <- games %>%
  select(starts_with("Genre")) %>%
  mutate_all(~ifelse(. == "True", 1, 0))
game_genres$GenreIsAll=NULL
game_genres<-game_genres %>% rename_with(~str_remove(., "GenreIs"))

# Calculate the co-occurrence matrix
game_genres <- as.matrix(game_genres)
co_occur <- t(game_genres) %*% game_genres
diag(co_occur) <- 0


my_colors <- c("#a6cee3",
  "#1f78b4",
  "#b2df8a",
  "#33a02c",
  "#fb9a99",
  "#e31a1c",
  "#fdbf6f",
  "#ff7f00",
  "#cab2d6",
  "#6a3d9a",
  "#ffff99",
  "#b15928")

# Create an interactive chord diagram
chorddiag(co_occur,  groupColors = my_colors)
chorddiag(co_occur)
