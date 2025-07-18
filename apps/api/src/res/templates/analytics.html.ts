export const analyticsHtml = (
  totalRevenue: number,
  currentMonthSubscribers: number,
  articleAnalytics: any[],
  athletesEarning: any[]
) => {
  const year = new Date().getFullYear();

  return `
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Analytics Dashboard</title>
  </head>
  <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 1200px; margin: 0 auto; padding: 20px;">
    <div style="background-color: #9e08d4; color: white; padding: 20px; text-align: center; border-radius: 5px 5px 0 0;">
      <h1>Analytics Dashboard</h1>
    </div>
    <div style="background-color: #ffffff; padding: 20px; border: 1px solid #e0e0e0; border-radius: 0 0 5px 5px;">
      <div style="background-color: #ffffff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 20px;">
        <h2 style="color: #2c3e50; margin-bottom: 10px;">Revenue</h2>
        <div style="font-size: 36px; font-weight: bold; color: #3498db;">$${totalRevenue}</div>
        <p style="color: #7f8c8d;">Total Platform Revenue</p>
      </div>
      <div style="background-color: #ffffff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 20px;">
        <h2 style="color: #2c3e50; margin-bottom: 10px;">Subscribers</h2>
        <div style="font-size: 36px; font-weight: bold; color: #3498db;">${currentMonthSubscribers}</div>
        <p style="color: #7f8c8d;">Current Month Subscribers</p>
      </div>
      <div style="background-color: #ffffff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 20px;">
        <h2 style="color: #2c3e50; margin-bottom: 20px;">Article Performance</h2>
        <table style="width: 100%; border-collapse: collapse;">
          <thead>
            <tr style="background-color: #f5f5f5;">
              <th style="padding: 12px; text-align: left; border-bottom: 1px solid #ddd;">Title</th>
              <th style="padding: 12px; text-align: left; border-bottom: 1px solid #ddd;">Views</th>
              <th style="padding: 12px; text-align: left; border-bottom: 1px solid #ddd;">Subscriptions</th>
            </tr>
          </thead>
          <tbody>
            ${articleAnalytics
              .map(
                (article) => `
            <tr>
              <td style="padding: 12px; border-bottom: 1px solid #ddd;">${article.title}</td>
              <td style="padding: 12px; border-bottom: 1px solid #ddd;">${article.views}</td>
              <td style="padding: 12px; border-bottom: 1px solid #ddd;">${article.subscriptions}</td>
            </tr>
            `
              )
              .join("")}
          </tbody>
        </table>
      </div>
      <div style="background-color: #ffffff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 20px;">
        <h2 style="color: #2c3e50; margin-bottom: 20px;">Athletes Leaderboard</h2>
        <table style="width: 100%; border-collapse: collapse;">
          <thead>
            <tr style="background-color: #f5f5f5;">
              <th style="padding: 12px; text-align: left; border-bottom: 1px solid #ddd;">Name</th>
              <th style="padding: 12px; text-align: left; border-bottom: 1px solid #ddd;">Total Earning</th>
              <th style="padding: 12px; text-align: left; border-bottom: 1px solid #ddd;">Total Revenue</th>
            </tr>
          </thead>
          <tbody>
            ${athletesEarning
              .map(
                (athlete) => `
            <tr>
              <td style="padding: 12px; border-bottom: 1px solid #ddd;">${athlete.name}</td>
              <td style="padding: 12px; border-bottom: 1px solid #ddd;">$${athlete.totalEarning}</td>
              <td style="padding: 12px; border-bottom: 1px solid #ddd;">$${athlete.totalRevenue}</td>
            </tr>
            `
              )
              .join("")}
          </tbody>
        </table>
      </div>
    </div>
    <div style="text-align: center; margin-top: 20px; font-size: 12px; color: #666">
      <p>© ${year} Thenaritiv. All rights reserved.</p>
    </div>
  </body>
</html>`;
};

export default analyticsHtml;
