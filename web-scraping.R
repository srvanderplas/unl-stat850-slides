library(rvest)
library(xml2)
library(purrr)
library(tidyverse)
url <- "https://www.catbreedslist.com/all-cat-breeds/american-shorthair.html"
html <- read_html(url)
html

all_breeds <- "https://www.catbreedslist.com/cat-breeds-a-z/"

cat_info_links <- all_breeds %>%
  read_html() %>%
  # Add an a to the SelectorGadget CSS search
  html_elements(css = ".all-a-z dd a") %>%
  # Use xml_attr to get the href parameter
  map_chr(xml_attr, attr = "href")

# Let's make a tibble:
cat_breeds <- tibble(url = cat_info_links) %>%
  # Make the link valid by adding the front part
  mutate(url = paste0("http://catbreedslist.com", url)) %>%
  # Read each page in
  mutate(page = map(url, read_html))

cat_breeds[1,]

cat_breeds <- cat_breeds %>%
  mutate(name = map(page, html_element, "h1") %>%
           map_chr(html_text))

cat_breeds$name

cat_breeds <- cat_breeds %>%
  filter(!is.na(name))

# Start at the top of the page with the images
cat_breeds <- cat_breeds %>%
  # Get all images on the page in slides
  mutate(images = map(page, html_elements, ".Slides img")) %>%
  # Pull out each image's src link
  mutate(img_src = images %>%
           # Since each page has multiple images,
           # we need nested map statements... eww
           map(.f = ~map_chr(., xml_attr, "src")))

cat_breeds$img_src[[1]]
cat_breeds$img_src[[3]]

cat_breeds <- cat_breeds %>%
  mutate(breed_info = map(page, html_element, css = ".table-01"))

# Check to make sure each page has a table
# View(cat_breeds)

cat_breeds_info <- cat_breeds %>%
  filter(map_int(breed_info, length) > 0) %>%
  mutate(breed_info = map(breed_info, html_table))

cat_breeds_info$breed_info[[1]]

cat_breeds_info <- cat_breeds %>%
  mutate(characteristics = map(page, html_element, css = ".table-02")) %>%
  mutate(characteristics = map(characteristics, html_table)) %>%
  mutate(characteristics = map(characteristics, set_names, c("char_name", "value")))

cat_breeds_info$characteristics[[1]]

cat_breeds_info %>% unnest(characteristics)
