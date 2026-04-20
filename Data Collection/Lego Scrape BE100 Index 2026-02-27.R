library(rvest)
library(stringr)
library(readr)

# Replace all [1] with [itemcount] after for full loop of 100 sets

itemlist = readLines("https://www.brickeconomy.com/sets/index")
itemlinks = itemlist[str_detect(itemlist, "h4.*a href.*/set/[0-9]+|h4.*a href.*/minifig/[0-9]+")] # 7099
itemlinks = str_extract(itemlinks, "/set/.*>[0-9]|/minifig/.*>[0-9]") # to do: The same for minifigs
itemlinks = str_sub(itemlinks, end=-4)
itemlinks = paste0("https://www.brickeconomy.com", itemlinks)
itemlinks = itemlinks[-65]

for (itemcount in 1:length(itemlinks))
{
  itemtext = readLines(itemlinks[itemcount])
  itemdata = itemtext[str_detect(itemtext, "new Date\\(")][3]

  itemdata = unlist(str_split(itemdata, "new Date"))
  itemdata = str_extract(itemdata, ".*\\.[0-9]{2}")
  itemdata = str_replace_all(itemdata, "\\(|\\)", "")
  itemdata = str_replace_all(itemdata, " ", "")
  itemdata = str_split_fixed(itemdata, ",", 8)[-1, -8]

  if(nrow(itemdata) >= 1)
  {
    itemyear = itemdata[,1]
    itemmonth = itemdata[,2]
    itemday = itemdata[,3]
    itemprice_lowerbound = itemdata[,4]
    itemprice_lower = itemdata[,5]
    itemprice_upper = itemdata[,6]
    itemprice_upperbound = itemdata[,7]
  
    # Get the ID of the set  7099-1
    itemid = str_extract(itemlinks[itemcount], "/[0-9-]+/")
    itemid = str_replace_all(itemid, "/" , "")
  
    itemname = str_extract(itemlinks[itemcount], "[A-Za-z0-9-]+$")
    itemurl = itemlinks[itemcount]
  
    df_item = data.frame(itemurl, itemid, itemname, itemyear, itemmonth, itemday, itemprice_lowerbound, itemprice_lower, itemprice_upper, itemprice_upperbound)
  
    if(itemcount == 1)
    {
      df_all = df_item
    }
    if(itemcount > 1)
    {
      df_all = rbind(df_all, df_item)
    }
  }
  Sys.sleep(10)
}  


write_csv(df_all, "output.csv")

