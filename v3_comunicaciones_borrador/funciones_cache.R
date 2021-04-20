func_save <- function(x){
  
  if(exists(x)){
    save(x, file = 'caches.RData')
  } else{
    NULL
  }
}

func_load <- function(x){
  if(exists(x)){
    load(x)
  }
}