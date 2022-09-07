# Packages ----------------------------------------------------------------
library(tidyverse)
library(qualtRics)

# Online Sample -----------------------------------------------------------
icar_mturk <-
  fetch_survey(
    surveyID ="SV_3t3VCcq88o8DE6F",
    verbose  = T,
    force_request = T,
    label = F,
    convert = F
  ) |>
  rename_with(~tolower(.x) |> str_replace(" ", "_")) |>
  mutate(
    sample              = "online",
    time_condition      = ifelse(condition==0, computer_page_submit,recession_page_submit),
    time_icar           = across(matches("(ln|vr|mx|r3d)_\\d\\d_page_submit$")) |> rowSums(),
    time_ln             = across(matches("ln_\\d\\d_page_submit$")) |> rowSums(),
    time_mx             = across(matches("mx_\\d\\d_page_submit$")) |> rowSums(),
    time_vr             = across(matches("vr_\\d\\d_page_submit$")) |> rowSums(),
    time_r3d            = across(matches("r3d_\\d\\d_page_submit$")) |> rowSums(),
    dems_gender         = ifelse(gender == 12, -1, 1),
    dems_age            = age,
    dems_ethnicity      = ethnicity,
    dems_edu            = education,
    dems_us_born        = us,
    dems_english_native = growup,
    dems_fluency        = fluency,
    dems_lang           = language,
    att_interrupt       = interrupt,
    att_one_sitting     = sitting,
    att_getup           = getup
  ) |>
  select(
    sample,
    condition,
    starts_with("chld"),
    starts_with("curr_"),
    matches("^(ln|vr|mx|r3d)_\\d\\d$"),
    starts_with("dems"),
    starts_with("att"),
    starts_with("time")
  ) |>
  sjlabelled::var_labels(
    sample = "Lab or online subsample",
    condition = "Experimental condition, 0 = control (computer crash); 1 = experimental (recession)"
  )

# Lab Sample --------------------------------------------------------------
icar_lab <-
  fetch_survey(
    surveyID = "SV_9GDc3kaCRw9lGQt",
    verbose  = T,
    force_request = T,
    label = F,
    convert = F
  ) |>
  rename_with(~tolower(.x) |> str_replace(" ", "_")) |>
  mutate(
    sample              = "lab",
    time_condition      = ifelse(condition==0, computer_page_submit,recession_page_submit),
    time_icar           = across(matches("(ln|vr|mx|r3d)_\\d\\d_page_submit$")) |> rowSums(),
    time_ln             = across(matches("ln_\\d\\d_page_submit$")) |> rowSums(),
    time_mx             = across(matches("mx_\\d\\d_page_submit$")) |> rowSums(),
    time_vr             = across(matches("vr_\\d\\d_page_submit$")) |> rowSums(),
    time_r3d            = across(matches("r3d_\\d\\d_page_submit$")) |> rowSums(),
    dems_gender         = ifelse(gender == 12, -1, 1),
    dems_age            = age,
    dems_ethnicity      = ethnicity,
    dems_edu            = education,
    dems_us_born        = us,
    dems_english_native = growup,
    dems_fluency        = fluency,
    dems_lang           = language,
    att_interrupt       = interrupt,
    att_one_sitting     = sitting,
    att_getup           = getup
  ) |>
  select(
    sample,
    condition,
    starts_with("chld"),
    starts_with("curr_"),
    matches("^(ln|vr|mx|r3d)_\\d\\d$"),
    starts_with("dems"),
    starts_with("att"),
    starts_with("time")
  )

# Combined Data -----------------------------------------------------------
icar_data <-
  bind_rows(icar_mturk, icar_lab) |>
  sjlabelled::copy_labels(icar_mturk) |>
  rename_with(.cols = starts_with("chld_unp_o"), .fn =  ~paste0("child_unp_obj", 1:3)) |>
  rename_with(.cols = starts_with("chld_chngs"), .fn =  ~paste0("child_unp_changes", 1:4)) |>
  rename_with(.cols = starts_with("chld_unp_"), .fn =  ~paste0("child_unp_subj", 1:8)) |>
  rename_with(.cols = starts_with("chld_ses_"), .fn =  ~paste0("child_ses_subj", 1:3)) |>
  rename_with(.cols = matches("^curr_(jobs|res|famly)"), .fn = ~paste0("current_unp_obj", 1:3)) |>
  rename_with(.cols = matches("^curr_ses_"), .fn = ~paste0("current_ses", 1:3)) |>
  rename(child_income = chld_inc, current_income = curr_inc) |>
  mutate(across(matches("(ln|vr|mx|r3d)_\\d\\d$"), ~ifelse(.x == 1, 1, 0))) |>
  mutate(across(matches("att_"), ~ifelse(.x == 1, 1, 0))) |>
  sjlabelled::copy_labels(icar_mturk) |>
  sjlabelled::set_labels(
    starts_with("vr_"), starts_with("mx_"), starts_with("r3d_"), starts_with("ln_"),
    labels = c("correct" = 1,  "incorrect" = 0)
  ) |>
  mutate(
    unp_obj_mean     = across(matches("child_unp_obj\\d$")) |> rowMeans(na.rm = TRUE),
    unp_changes_mean = across(matches("child_unp_changes\\d$")) |> rowMeans(na.rm = TRUE),
    unp_subj_mean    = across(matches("child_unp_subj\\d$")) |> rowMeans(na.rm = TRUE),
    ses_subj_mean    = across(matches("child_ses_subj\\d$")) |> rowMeans(na.rm = TRUE),
    icar_sum      = across(matches("(ln|vr|mx|r3d)_\\d\\d$")) |> rowSums(),
    ln_sum        = across(matches("ln_\\d\\d$")) |> rowSums(),
    mx_sum        = across(matches("mx_\\d\\d$")) |> rowSums(),
    vr_sum        = across(matches("vr_\\d\\d$")) |> rowSums(),
    r3d_sum       = across(matches("r3d_\\d\\d$")) |> rowSums()
  ) |>
  sjlabelled::var_labels(
    dems_gender = "What gender do you identify with?",
    dems_ethnicity = "What is your ethnicity?",
    sample = "Lab or online subsample",
    time_condition = "Time in seconds the experimental manipulation displayed (should be about 60 seconds)",
    time_icar      = "Time in seconds it took to complete the whole ICAR battery",
    time_ln        = "Time in seconds it took to complete the lettter-number items",
    time_mx        = "Time in seconds it took to complete the matrix reasoning items",
    time_r3d       = "Time in seconds it took to complete the 3d rotation items",
    time_vr        = "Time in seconds it took to complete the verbal reasoning items",
    icar_sum       = "Total score (out of 16) on the ICAR battery",
    ln_sum         = "Total score (out of 4) on the letter-number items",
    mx_sum         = "Total score (out of 4) on the matrix reasoning items",
    r3d_sum        = "Total score (out of 4) on the 3d rotation items",
    vr_sum         = "Total score (out of 4) on the verbal reasoning items",
    unp_obj_mean     = "Childhood unpredictability (objective) mean score",
    unp_changes_mean = "Childhood unpredictability (changes) mean score",
    unp_subj_mean    = "Childhood unpredictability (subjective) mean score",
    ses_subj_mean    = "Childhood socioeconomic status (objective) mean score"
  ) |>
  sjlabelled::set_labels(
    condition,
    labels = c("computer crash" = 0, "recession" = 1)
  ) |>
  sjlabelled::set_labels(
    starts_with("child_unp_obj"),
    labels = c(
      "never",
      "only once",
      "a couple of times",
      "several times",
      "many times"
    )
  ) |>
  sjlabelled::set_labels(
    starts_with("child_unp_changes"),
    labels = c(
      "the same all the time",
      "some changes",
      "relatively frequent changes",
      "many changes all the time",
      "constant and rapid changes"
    )
  ) |>
  sjlabelled::set_labels(
    starts_with("child_unp_subj"),
    labels = c("not at all" = 1, "somewhat" = 4, "Extremely" = 7)
  ) |>
  sjlabelled::set_labels(
    starts_with("child_ses_subj"),
    labels = c("stronly disagree" = 1,  "strongly agree" = 7)
  ) |>
  sjlabelled::set_labels(
    ends_with("income"),
    labels =
      c(
        "< $15k" = 1,
        "$15k - $25k" = 2,
        "$25k - $35k" = 3,
        "$35k - $50k" = 4,
        "$50k - $75k" = 5,
        "$75k - $100k" = 6,
        "$100k - $150k" = 7,
        "$150k >" = 8
      )
  ) |>
  sjlabelled::set_labels(
    starts_with("att_"),
    labels = c("yes" = 1, "no" = 0)
  ) |>
  sjlabelled::set_labels(
    dems_gender,
    labels = c(
      "male" = -1,
      "female" = 1,
      "missing or does not identify with either" = NA
    )
  ) |>
  sjlabelled::set_labels(
    dems_ethnicity,
    labels = c(
      "Asian" = 1,
      "Black" = 2,
      "Latino" = 3,
      "White" = 4,
      "Native American" = 5,
      "Pacific Islander" = 6, "
      Mixed" = 7,
      "Other" = 8
    )
  ) |>
  sjlabelled::set_labels(
    dems_edu,
    labels = c(
      "Some high school or less" = 1,
      "High school diploma or equivalent" = 2,
      "Some college/university" = 3,
      "College/university diploma" = 4,
      "Some graduate school" = 5,
      "Graduate degree." = 6
    )
  ) |>
  sjlabelled::set_labels(
    dems_us_born,
    labels = c(
      "Yes" = 1,
      "No" = 2,
      "Partly" = 3
    )
  ) |>
  sjlabelled::set_labels(
    dems_english_native, dems_lang,
    labels = c(
      "Yes" = 1,
      "No" = 2
    )
  ) |>
  sjlabelled::set_labels(
    dems_fluency,
    labels = c(
      "Not at all fluent" = 1,
      "Extremely fluent" = 7
    )
  ) |>
  select(
    sample,
    condition,
    starts_with("dems"),
    starts_with("child"),
    ends_with("mean"),
    matches("^(ln|vr|mx|r3d)"),
    matches("^icar"),
    starts_with("time"),
    starts_with("att")
  )

# Codebook ----------------------------------------------------------------
icar_data_codebook <-
  map_df(names(icar_data), function(x){
    var_label <-
      glue::glue("icar_data${x}") |>
      rlang::parse_expr() |>
      rlang::eval_tidy() |>
      attr("label")

    value_label <-
      glue::glue("icar_data${x}") |>
      rlang::parse_expr() |>
      rlang::eval_tidy() |>
      attr("labels")

    value_label <- paste(names(value_label), "=", value_label, collapse = ", ")

    tibble(
      var_name   = x,
      var_label  = ifelse(is.null(var_label), "", var_label),
      var_values = ifelse(value_label == " = ", "", value_label)
    )
  }) |>
  mutate(
    var_label = str_remove(var_label, ".* - "),
    var_label = ifelse(var_name == "child_income", "What was your household income when you were growing up?", var_label)
  )

usethis::use_data(icar_data, overwrite = TRUE)
usethis::use_data(icar_data_codebook, overwrite = TRUE)
