# Crime_Transportation_Analysis
## Objective
The rate of criminal homicide in the United States has declined by more than 50% since
the 1990s. Scholars have attributed this decline to increased policing, mass incarceration, and
greater neighborhood cohesion (Zimring 2006; Levitt 2004; Travis, Western, and Redburn 2014;
Sharkey, Torrats-Espinosa, and Taykar 2017). This study considers how structural characteristics
of neighborhoods, specifically public transportation access, affects criminal homicide in five
cities across the United States – Baltimore, MD; Chapel Hill, NC; Chicago, IL; Cincinnati, OH;
Los Angeles, CA; and New York City, NY. Using zero-inflated negative binomial models, I
find that a greater density of public transportation stops within a census tract is associated with a
smaller number of criminal homicide incidents. This relationship is more pronounced in
Chicago, Il; Los Angeles, CA; and Cincinnati, OH. Future studies should explore how public
transportation may prevent criminal homicide from occurring.
## Feature Engineering

First, each incident of crime was assigned a United States census tract code based on its
longitude and latitude. Each tract is populated by an average of 4,000 residents and are smaller
subdivisions of a county. Second, because districts provided varying levels of detail about crime
type for each incident, the descriptions had to be streamlined and standardized according to the
categories of violent crime as defined by the Federal Bureau of Investigation. The authors
utilized string matching techniques to convert local police crime descriptions to these standard
categories. These categories are: criminal homicide, forcible rape, robbery, aggravated assault,
burglary, larceny-theft, motor vehicle-theft, and arson. Third, a new dataframe was created to
summarize the incident data by census tract, such that the number of criminal homicide cases
that occurred would be available for each census tract. Hence, while the raw data observations
each represented a single incident, the data cleaning process yielded a dataset for each city in
which an observation represented a unique census tract.
Fourth, the authors calculated a density of public transportation stops per square mile in
every census tract. All the census tracts in each of the six cities were matched with the
geographic coordinates corresponding to public transportation stop locations, which were
extracted from each city’s respective general transit feed. The total number of stops in each tract
was divided by the area of the tract.

## Model Choice

the final model used is a zero-inflated negative binomial model.
This model is a modification of a negative binomial model. It is appropriate when the data is a
mixture of two processes – one that only produces zeros and one that follows a negative binomial
distribution. The simple Poisson model, , is not appropriate in this case for two reasons: first, the
data has a large number of census tracts with zero homicides. second, the Poisson model has the assumption that mean
and variance is equal which the data does not meet.

## Data Sources

<https://www.bjs.gov/content/pub/pdf/htus8008.pdf>
<https://www2.census.gov/geo/pdfs/education/CensusTracts.pdf>
<https://ucr.fbi.gov/crime-in-the-u.s/2010/crime-in-the-u.s.-2010/offense-definitions>
<https://collected.jcu.edu/cgi/viewcontent.cgi?article=1003&context=jep>
Crime Data: <https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-present-Dashboard5cd6-ry5g>
Chicago Transportation Authority: <https://www.transitchicago.com>
US Census Data: <https://opportunityinsights.org/data/>
