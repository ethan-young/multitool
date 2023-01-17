#' Early Life Adversity and Cognitive Ability
#'
#' An unpublished experiment looking at the effect priming economic threat and
#' childhood adversity on International Cognitive Ability Resource (ICAR) scores
#'
#' @format A data frame with {413} rows and {63} variables:
#' \describe{
#'   \item{sample}{Lab or online subsample}
#'   \item{condition}{Experimental condition, 0 = control (computer crash); 1 = experimental (recession)}
#'   \item{dems_gender}{What gender do you identify with?}
#'   \item{dems_age}{What is your AGE in years? (e.g. 25)}
#'   \item{dems_ethnicity}{What is your ethnicity?}
#'   \item{dems_edu}{What is the highest level of education you have completed?}
#'   \item{dems_us_born}{Did you grow up in the United States?}
#'   \item{dems_english_native}{Did you grow up speaking English?}
#'   \item{dems_fluency}{How fluent are you with the English language?}
#'   \item{dems_lang}{Is English the language you know best?}
#'   \item{child_unp_obj1}{How many times did your parents or legal guardians change jobs or occupational status?}
#'   \item{child_unp_obj2}{How many times did you move or change residence (move to a different house, neighborhood, city, or state)?}
#'   \item{child_unp_obj3}{How many times were there changes in your familial circumstances? (divorce, parents starting new relationships, parents leaving the home)}
#'   \item{child_unp_changes1}{Economic status:}
#'   \item{child_unp_changes2}{Family environment:}
#'   \item{child_unp_changes3}{Your childhood neighborhood environment:}
#'   \item{child_unp_changes4}{Your childhood school environment:}
#'   \item{child_unp_subj1}{My family life was generally inconsistent and unpredictable from day-to-day.}
#'   \item{child_unp_subj2}{My parent(s) frequently had arguments or fights with each other or other people in my childhood.}
#'   \item{child_unp_subj3}{My parents had a difficult divorce or separation during this time.}
#'   \item{child_unp_subj4}{People often moved in and out of my house on a pretty random basis.}
#'   \item{child_unp_subj5}{When I woke up, I often didn't know what could happen in my house that day.}
#'   \item{child_unp_subj6}{My family environment was often tense and "on edge".}
#'   \item{child_unp_subj7}{Things were often chaotic in my house.}
#'   \item{child_unp_subj8}{I had a hard time knowing what my parent(s) or other people in my house were going to say.}
#'   \item{child_ses_subj1}{I grew up in a relatively wealthy neighborhood.}
#'   \item{child_ses_subj2}{I felt relatively wealthy compared to the other kids.}
#'   \item{child_ses_subj3}{My family usually had enough money for things when I was growing up.}
#'   \item{child_income}{What was your household income when you were growing up?}
#'   \item{unp_obj_mean}{Childhood unpredictability (objective) mean score}
#'   \item{unp_changes_mean}{Childhood unpredictability (changes) mean score}
#'   \item{unp_subj_mean}{Childhood unpredictability (subjective) mean score}
#'   \item{ses_subj_mean}{Childhood socioeconomic status (objective) mean score}
#'   \item{vr_04}{Verbal reasoning item 4}
#'   \item{vr_17}{Verbal reasoning item 17}
#'   \item{ln_07}{Letter-number item 7}
#'   \item{ln_58}{Letter-number item 58}
#'   \item{mx_45}{Matrix reasoning item 45}
#'   \item{mx_46}{Matrix reasoning item 46}
#'   \item{r3d_06}{Mental Rotation item 6}
#'   \item{r3d_08}{Mental Rotation item 8}
#'   \item{vr_16}{Verbal reasoning item 16}
#'   \item{vr_19}{Verbal reasoning item 19}
#'   \item{ln_33}{Letter-number item 33}
#'   \item{ln_34}{Letter-number item 34}
#'   \item{mx_47}{Matrix reasoning item 47}
#'   \item{mx_55}{Matrix reasoning item 55}
#'   \item{r3d_03}{Mental Rotation item 3}
#'   \item{r3d_04}{Mental Rotation item 4}
#'   \item{ln_sum}{Total score (out of 4) on the letter-number items}
#'   \item{mx_sum}{Total score (out of 4) on the matrix reasoning items}
#'   \item{vr_sum}{Total score (out of 4) on the verbal reasoning items}
#'   \item{r3d_sum}{Total score (out of 4) on the 3d rotation items}
#'   \item{icar_sum}{Total score (out of 16) on the ICAR battery}
#'   \item{time_condition}{Time in seconds the experimental manipulation displayed (should be about 60 seconds)}
#'   \item{time_icar}{Time in seconds it took to complete the whole ICAR battery}
#'   \item{time_ln}{Time in seconds it took to complete the lettter-number items}
#'   \item{time_mx}{Time in seconds it took to complete the matrix reasoning items}
#'   \item{time_vr}{Time in seconds it took to complete the verbal reasoning items}
#'   \item{time_r3d}{Time in seconds it took to complete the 3d rotation items}
#'   \item{att_interrupt}{Were you ever interrupted by anyone or anything during the time you spent on this survey?}
#'   \item{att_one_sitting}{Did you complete this survey in one sitting?}
#'   \item{att_getup}{Did you ever get up and leave your computer during the study (for any reason)?}
#' }
#' @source \url{data_URL}
"icar_data"
