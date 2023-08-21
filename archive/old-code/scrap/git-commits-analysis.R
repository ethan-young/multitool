my_commits <- gh::gh("/repos/{owner}/{repo}/commits", owner = "ethan-young", repo = "multitool")

my_commits |>
  map_df(function(x){
    tibble(
      message = x[["commit"]][["message"]],
      date    = x[["commit"]][["author"]][["date"]],
      url     = x[["commit"]][["url"]]
    )


  }) |>
  separate(message, into = c("message", "meta"), sep = "\n\n")

my_commits[[1]]$commit$url

gh::gh(my_commits[[14]][["url"]])
