## ---- echo = T-----------------------------------------------------------------------------
## Set up - short version
library(tidyverse)


## ------------------------------------------------------------------------------------------
logical_vec <- c(T, T, F, F)
numeric_vec <- c(3, 1, 4, 5)
character_vec <- c("cats", "rule", "dogs", "drool") 
# not really! but it doesn't make sense if you switch it...


## ------------------------------------------------------------------------------------------
character_vec[c(1, 3)]
character_vec[logical_vec]


## ------------------------------------------------------------------------------------------
my_list <- list(
  first = logical_vec,
  second = list(
    c("Another", "list"), 
    c("With", "2", "vectors")),
  
  # even model results
  third = lm(numeric_vec ~ 1), 
  
  # And empty entries!
  fourth = NULL, 
  
  # and unnamed things
  "Unnamed stuff" 
)

my_list


## ------------------------------------------------------------------------------------------
# By position, 
# using []
#
my_list[2] 


## ------------------------------------------------------------------------------------------
# By $name
#
#
my_list$second


## ------------------------------------------------------------------------------------------
# By position
# or name, 
# using [[]]
my_list[[2]]


## ------------------------------------------------------------------------------------------
download.file("http://bit.ly/cat-breeds-data",
              "cat_breeds.Rdata", 
              mode = "wb") # for the windows users
load("cat_breeds.Rdata")












## ----load-pkgs, eval = T, include = F, cache = F-------------------------------------------
library(purrr)
download.file("http://bit.ly/dog-breed-data",
              "dog_breeds.Rdata", 
              mode = "wb") # for the windows users
load("dog_breeds.Rdata")


## ------------------------------------------------------------------------------------------
length(dogs)
names(dogs[[1]])


## ------------------------------------------------------------------------------------------
dogs[[1]]


## ------------------------------------------------------------------------------------------
map(dogs[1:10], "name")


## ------------------------------------------------------------------------------------------
map_chr(dogs[1:10], "name")


## ---- error = T----------------------------------------------------------------------------
map_int(dogs[1:10], "name")


## ------------------------------------------------------------------------------------------
dogs[1:10] %>%
  map_chr("name") %>% # get names out and convert to vector
  tibble(breed = .) %>% # Create a table
  mutate(length = map_int(breed, nchar)) # get name length in new col


## ----tryitout-map-chr-solution, echo = F---------------------------------------------------
cat_urls <- map_chr(cats, 2)






## ----animate-cats, echo = T, fig.align = "center"------------------------------------------
library(magick)
ims <- map(cat_urls[1:10], image_read) %>% image_join()
image_animate(ims, fps = 2)


## ------------------------------------------------------------------------------------------
tmp <- map(dogs, `[`, c("name", "image_link"))
tmp[[221]]




## ------------------------------------------------------------------------------------------
# There are several extract functions in different pkgs
# use magrittr::extract to get the one we need
dog_df <- map_df(dogs, magrittr::extract, 
                 c("name", "image_link"))









## ------------------------------------------------------------------------------------------
# What about the characteristics?
dogs[[1]]$characteristics 


## ------------------------------------------------------------------------------------------
fix_characteristics <- function(x) 
  tibble(characteristic = names(x), 
         rating = as.numeric(x))

fix_characteristics(dogs[[1]]$characteristics)




## ------------------------------------------------------------------------------------------
dog_df$characteristics <- map(dogs, "characteristics") %>% 
           map(fix_characteristics)

select(dog_df, name, characteristics)




## ------------------------------------------------------------------------------------------
select(dog_df, name, characteristics) %>%
  unnest(characteristics)


## ---- fig.width = 8, fig.height = 4, fig.align = "center"----------------------------------
select(dog_df, name, characteristics) %>% unnest(characteristics) %>%
  ggplot(aes(x = rating)) +  geom_bar() + 
  facet_wrap(~characteristic, nrow = 2)

