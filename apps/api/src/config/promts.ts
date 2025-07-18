export const PROMPTS = {
  system:
    "You are an AI that generates articles based on survey responses. Your articles should be well-structured, engaging, and include relevant image suggestions. Whenever possible, suggest image ideas that could be sourced from platforms like Pexels or Pinterest.",

  summary: (surveyTitle: string, responses: string) =>
    `Based on the following survey responses, generate a concise summary in plain text. Additionally, suggest relevant images that could accompany the summary. These images should be sourced from platforms like Pexels or Pinterest. Provide descriptive keywords for image searches.\n\nSurvey: ${surveyTitle}\nResponses:\n${responses}\n\nInclude a section at the end labeled "Suggested Images" with relevant image descriptions and possible search keywords.`,

  calm: (surveyTitle: string, responses: string) =>
    `Based on the following survey responses, generate a calm, long, and cool article. The article should be captivating, easy to read, and include suggestions for relevant images that could enhance the reading experience. These images should be sourced from platforms like Pexels or Pinterest.\n\nSurvey: ${surveyTitle}\nResponses:\n${responses}\n\nAt the end of the article, include a "Suggested Images" section with detailed descriptions and keywords for finding suitable images.`,

  flashy: (surveyTitle: string, responses: string) =>
    `Based on the following survey responses, generate a flashy, long, and exciting article. The article should be dynamic, engaging, and visually appealing. Suggest appropriate images that could be sourced from Pexels or Pinterest to enhance the article.\n\nSurvey: ${surveyTitle}\nResponses:\n${responses}\n\nAt the end of the article, include a "Suggested Images" section with image descriptions and search terms for finding relevant visuals.`,
};
