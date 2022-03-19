function expectOK(testCase) {
  return true;
}

function expectCards(testCase) {
  if (testCase.expected != null) {
    return (
      testCase.expected.YesRecommendation != null ||
      testCase.expected.NeedMoreInformation != null
    );
  }
}

function expectCardsContent(testCase) {
  if (expectCards(testCase)) {
    const cardArray = [];
    if (testCase.expected.YesRecommendation != null) {
      cardArray.push({
        uuid: 4,
        summary: "Statin Use for the Primary Prevention of CVD",
        indicator: "info",
        detail: testCase.expected.YesRecommendation + testCase.expected.ExclusionCriteria,
        source: {
          label:
            "CDS Connect: Statin Use for the Primary Prevention of CVD in Adults",
          url: "https://cds.ahrq.gov/cdsconnect/artifact/statin-use-primary-prevention-cvd-adults",
        },
        overrideReasons: [
          {
            uuid: 4,
            display: "Done reviewing",
          },
        ],
        extension: {
          grade: testCase.expected.RecommendationGrade,
          rationale: testCase.expected.Rationale,
        },
      });
    }
    if (testCase.expected.NeedMoreInformation != null) {
      cardArray.push({
        summary: "More information needed to complete Statin Use assessment",
        indicator: "warning",
        detail: testCase.expected.NeedMoreInformation,
        source: {
          label:
            "CDS Connect: Statin Use for the Primary Prevention of CVD in Adults",
          url: "https://cds.ahrq.gov/cdsconnect/artifact/statin-use-primary-prevention-cvd-adults",
        },
      });
    }
    return cardArray;
  }
}

module.exports = { expectOK, expectCards, expectCardsContent };
