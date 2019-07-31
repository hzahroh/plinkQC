context('Test utility functions')

context('Test relatednessFilter')
# create test data
single <- data.frame(ID1 = paste(LETTERS[1:10], 1:10, sep=""),
                 ID2 = paste(LETTERS[11:20], 1:10, sep=""),
                 values = runif(10, 0.22, 0.89), stringsAsFactors=FALSE)
multiple <- data.frame(ID1 = paste(LETTERS[1:10], 21:30, sep=""),
                     ID2 = paste(LETTERS[c(5,5,2,2,3,3,3,3,6,6)],
                                 c(21:30)[c(5,5,2,2,3,3,3,3,6,6)], sep=""),
                     values = runif(10, 0.22, 0.89), stringsAsFactors=FALSE)
nonrelated <- data.frame(ID1 = paste(LETTERS[1:10], 31:40, sep=""),
                         ID2 = paste(LETTERS[11:20], 31:40, sep=""),
                         values = runif(10, 0.01, 0.1), stringsAsFactors=FALSE)
expectedfail <- c(single$ID1, unique(multiple$ID2))

df <- rbind(single, multiple, nonrelated)
df_diagonal <- rbind(df, df[,c(2,1,3)])
df_other <- data.frame(IID=unique(c(df$ID1, df$ID2)))
df_other$values <- 0.6

test_that('relatednessFilter throws missing relatedness IID1 column error',{
    expect_error(relatednessFilter(df,relatednessIID1="IID1",
                                   relatednessIID2="ID2",
                                   relatednessRelatedness="values"),
                 "Column IID1 for relatedness not found")
})

test_that('relatednessFilter throws missing relatedness IID2 column error',{
    expect_error(relatednessFilter(df,relatednessIID1="ID1",
                                   relatednessIID2="IID2",
                                   relatednessRelatedness="values"),
                 "Column ID1 for relatedness not found")
})

test_that('relatednessFilter throws missing relatednessTh error',{
    expect_error(relatednessFilter(df,relatednessIID1="ID1",
                                   relatednessIID2="ID2",
                                   relatednessRelatedness="values"),
                 "argument \"relatednessTh\" is missing, with no default")
})


test_that('relatednessFilter throws missing relatedness FID1 column error',{
    expect_error(relatednessFilter(df,relatednessIID1="ID1",
                                   relatednessIID2="ID2",
                                   relatednessFID1="FID1",
                                   relatednessFID2="FID2",
                                   relatednessRelatedness="values"),
                 "Column FID1 for relatedness not found")
})

test_that('relatednessFilter throws missing otherCriterion IID1 column error',{
    expect_error(relatednessFilter(df,relatednessIID1="ID1",
                                   relatednessIID2="ID2",
                                   relatednessTh=0.185,
                                   relatednessRelatedness="values",
                                   otherCriterion = df_other,
                                   otherCriterionIID = "IID1",
                                   otherCriterionMeasure = "values"),
                 "Column IID1 for otherCriterion not found")
})

test_that('relatednessFilter throws missing otherCriterion Measure column error',{
    expect_error(relatednessFilter(df,relatednessIID1="ID1",
                                   relatednessIID2="ID2",
                                   relatednessTh=0.185,
                                   relatednessRelatedness="values",
                                   otherCriterion = df_other,
                                   otherCriterionIID = "ID1",
                                   otherCriterionMeasure = "measure"),
                 "Column measure for otherCriterion not found")
})

test_that('relatednessFilter throws colname specification error',{
    expect_error(relatednessFilter(df, relatednessFID1="FID",
                                   relatednessIID1="ID1",
                                   relatednessIID2="ID2",
                                   relatednessRelatedness="values"),
                 "Either none or both, relatednessFID1 and relatednessFID2")
})

test_that('relatednessFilter throws missing otherCriterion Measure column error',{
    expect_message(relatednessFilter(df,relatednessIID1="ID1",
                                   relatednessIID2="ID2",
                                   relatednessTh=0.185,
                                   relatednessRelatedness="values",
                                   otherCriterion = df_other,
                                   otherCriterionIID = "IID",
                                   otherCriterionMeasure = "values",
                                   otherCriterionTh=0.5,
                                   otherCriterionThDirection='gt',
                                   verbose=TRUE),
                 "Relatedness cannot be evaluated as all individuals")
})

test_that('relatednessFilter throws missing otherCriterion error',{
    expect_error(relatednessFilter(df,relatednessIID1="ID1",
                                     relatednessIID2="ID2",
                                     relatednessTh=0.185,
                                     relatednessRelatedness="values",
                                     otherCriterion = df_other[1:10,],
                                     otherCriterionIID = "IID",
                                     otherCriterionMeasure = "values",
                                     otherCriterionTh=0.5,
                                     otherCriterionThDirection='gt',
                                     verbose=TRUE),
                   "Not all IIDs provided in relatedness are contained in")
})

test_that('relatednessFilter returns correct fail IDs for plink genome-like file',{
    failIDs <- relatednessFilter(df, relatednessIID1="ID1",
                                   relatednessIID2="ID2",
                                   relatednessTh=0.185,
                                   relatednessRelatedness="values",
                                   verbose=TRUE)
    expect_true(all(failIDs$failIDs$IDs %in% expectedfail))
})


test_that('relatednessFilter only returns fail IDs for plink genome-like file',{
    failIDs <- relatednessFilter(df, relatednessIID1="ID1",
                                 relatednessIID2="ID2",
                                 relatednessTh=0.185,
                                 relatednessRelatedness="values",
                                 verbose=TRUE)
    expect_true(all(!nonrelated$ID1 %in% failIDs$failIDs$IDs))
})

test_that('relatednessFilter returns correct fail IDs for diagonal-derived file',{
    failIDs <- relatednessFilter(df_diagonal, relatednessIID1="ID1",
                                 relatednessIID2="ID2",
                                 relatednessTh=0.185,
                                 relatednessRelatedness="values",
                                 verbose=TRUE)
    expect_true(all(failIDs$failIDs$IDs %in% expectedfail))
})


test_that('relatednessFilter only returns fail IDs for diagonal-derived file',{
    failIDs <- relatednessFilter(df_diagonal, relatednessIID1="ID1",
                                 relatednessIID2="ID2",
                                 relatednessTh=0.185,
                                 relatednessRelatedness="values",
                                 verbose=TRUE)
    expect_true(all(!nonrelated$ID1 %in% failIDs$failIDs$IDs))
})