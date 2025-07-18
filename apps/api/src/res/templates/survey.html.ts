export const surveyScheduleHtml = ({
  surveyTitle,
  surveyDescription,
  estimatedTime,
  takeSurveyNowLink,
  unsubscribeLink,
  preferencesLink,
}: {
  surveyTitle: string;
  surveyDescription: string;
  estimatedTime: number;
  takeSurveyNowLink: string;
  unsubscribeLink: string;
  preferencesLink: string;
}) => `
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Survey Schedule Template</title>
  </head>
  <body
    style="
      font-family: Arial, sans-serif;
      line-height: 1.6;
      color: #333;
      max-width: 600px;
      margin: 0 auto;
      padding: 20px;
    "
  >
    <div
      style="
        background-color: #9e08d4;
        color: white;
        padding: 20px;
        text-align: center;
        border-radius: 5px 5px 0 0;
      "
    >
      <h1>${surveyTitle} - Reminder</h1>
    </div>

    <div
      style="
        background-color: #ffffff;
        padding: 20px;
        border: 1px solid #e0e0e0;
        border-radius: 0 0 5px 5px;
      "
    >
      <p>Hello,</p>

      <p>
        This is a friendly reminder to complete the survey: ${surveyTitle}
      </p>

      <div
        style="
          background-color: #f8f9fa;
          padding: 15px;
          border-radius: 4px;
          margin: 20px 0;
        "
      >
        <p style="margin: 0"><strong>Survey Details:</strong></p>
        <p style="margin: 10px 0">${surveyDescription}</p>
        <p style="margin: 0">
          <strong>Time to complete:</strong> ${estimatedTime} minutes
        </p>
      </div>

      <!-- Scheduling Options -->
      <div style="margin: 20px 0">
        <a
          href="${takeSurveyNowLink}"
          style="
            display: block;
            background-color: #7c07b2;
            color: white;
            padding: 12px 24px;
            text-decoration: none;
            border-radius: 4px;
            margin-bottom: 10px;
            text-align: center;
          "
          >Take Survey Now</a
        >
      </div>

      <p>Thank you for your participation!</p>

      <p>
        Best regards,<br />
        The Survey Team
      </p>
    </div>

    <div
      style="text-align: center; margin-top: 20px; font-size: 12px; color: #666"
    >
      <p>© ${new Date().getFullYear()} Thenaritiv. All rights reserved.</p>
      <p>
        <a
          href="${unsubscribeLink}"
          style="color: #666; text-decoration: underline"
          >Unsubscribe</a
        >
        |
        <a
          href="${preferencesLink}"
          style="color: #666; text-decoration: underline"
          >Email Preferences</a
        >
      </p>
    </div>
  </body>
</html>
`;

export default surveyScheduleHtml;
