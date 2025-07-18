interface ArticleNotificationProps {
  article_title: string;
  article_summary: string;
  read_article_link: string;
  unsubscribe_link: string;
  preferences_link: string;
}

export const articleNotificationTemplate = (props: ArticleNotificationProps): string => {
  const year = new Date().getFullYear();
  return `
  <!DOCTYPE html>
  <html>
    <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Article Notification Template</title>
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
        <h1>Article Review Required</h1>
      </div>
  
      <div
        style="
          background-color: #ffffff;
          padding: 20px;
          border: 1px solid #e0e0e0;
          border-radius: 0 0 5px 5px;
        "
      >
        <p>A new article has been written about you and requires your review:</p>
  
        <div
          style="
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 4px;
            margin: 20px 0;
          "
        >
          <p style="margin: 0"><strong>Article Title:</strong></p>
          <p style="margin: 10px 0">${props.article_title}</p>
          
          <p style="margin: 0"><strong>Article Summary:</strong></p>
          <p style="margin: 10px 0">${props.article_summary}</p>
        </div>
  
        <div style="margin: 20px 0">
          <a
            href="${props.read_article_link}"
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
            >Review & Approve Article</a
          >
        </div>

        <div style="margin: 20px 0; padding: 15px; background-color: #f8f9fa; border-radius: 4px;">
          <p style="margin: 0 0 10px 0;"><strong>What happens next?</strong></p>
          <ol style="margin: 0; padding-left: 20px;">
            <li>Click the button above to read the full article</li>
            <li>Review the content carefully</li>
            <li>Choose to either approve or request changes</li>
            <li>If requesting changes, provide specific feedback</li>
          </ol>
        </div>

        <p style="color: #666; font-size: 14px;">
          Note: Your approval is required before this article can be published. If you don't take action within 7 days, the article will be automatically sent back for revision.
        </p>
      </div>
      <div
        style="text-align: center; margin-top: 20px; font-size: 12px; color: #666"
      >
        <p>© ${year} Thenaritiv. All rights reserved.</p>
        <p>
          <a
            href="${props.unsubscribe_link}"
            style="color: #666; text-decoration: underline"
            >Unsubscribe</a
          >
          |
          <a
            href="${props.preferences_link}"
            style="color: #666; text-decoration: underline"
            >Email Preferences</a
          >
        </p>
      </div>
    </body>
  </html>
  `;
};

export default articleNotificationTemplate;
