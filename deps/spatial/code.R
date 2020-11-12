library(sf)
# From https://catalog.data.gov/dataset/tiger-line-shapefile-2016-state-nebraska-current-county-subdivision-state-based
dat <- read_sf("deps/spatial/tl_2016_31_cousub.shp")

head(dat)

skimr::skim(dat)

library(ggplot2)
ggplot(data = dat) + geom_sf()


library(tidyverse)

counties <- dat %>%
  group_by(STATEFP, COUNTYFP) %>%
  summarize(geometry = st_union(geometry))


counties %>%
  ggplot() + geom_sf()

x[[1]][[1]] %>% plot()

# dat %>%
#   group_by(COUNTYFP) %>%
#   summarize(geometry = st_union(geometry)) %>%
#   mutate(geometry2 = st_simplify(geometry))

# From https://catalog.data.gov/dataset/tiger-line-shapefile-2018-state-nebraska-primary-and-secondary-roads-state-based-shapefile
roads <- read_sf("deps/spatial/tl_2018_31_prisecroads.shp")
head(roads)

ggplot() +
  geom_sf(data = counties, fill = "white") +
  geom_sf(data = roads, aes(color = RTTYP)) +
  theme_bw()

# From https://coronavirus-resources.esri.com/datasets/628578697fb24d8ea4c32fa0c5ae1843_0
covid <- read_csv("deps/spatial/COVID-19_Cases_US.csv") %>%
  # Fips codes
  mutate(STATEFP = stringr::str_sub(FIPS, 1, 2),
         COUNTYFP = stringr::str_sub(FIPS, 3, 5))

# Check what's there
counties %>%
  anti_join(covid, by = c("STATEFP", "COUNTYFP"))

# get population
# From https://www.census.gov/data/tables/time-series/demo/popest/2010s-counties-total.html
pop <- readxl::read_xlsx("deps/spatial/co-est2019-annres-31.xlsx", skip = 5,
                         col_names = c("county", "pop"), col_types = c("text", "numeric", rep("skip", 11))) %>%
  mutate(county = str_remove(county, "^\\.") %>% str_remove(., " County") %>% paste0(., ", US"))

pop %>%
  anti_join(covid, by = c("county" = "Combined_Key"))

covid <- covid %>%
  left_join(pop, by = c("Combined_Key" = "county"))

counties %>%
  left_join(covid, by = c("STATEFP", "COUNTYFP")) %>%
  mutate(rate = Confirmed/pop) %>%
  ggplot() +
  geom_sf(aes(fill = rate))


counties %>%
  left_join(covid, by = c("STATEFP", "COUNTYFP")) %>%
  mutate(rate = Confirmed/pop,
         county_name = str_remove(Combined_Key, ", Nebraska, US")) %>%
  ggplot() +
  geom_sf(aes(fill = rate)) +
  geom_text(aes(x = Long_, y = Lat, label = county_name), color = "white")
