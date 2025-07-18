import cron from 'node-cron';

// Process scheduled notifications every minute
cron.schedule('* * * * *', async () => {
  try {
    // Removed notificationService.processScheduledNotifications();
  } catch (error) {
    console.error('Error processing scheduled notifications:', error);
  }
});

// Clean up old notifications at midnight every day
cron.schedule('0 0 * * *', async () => {
  try {
    // Keep notifications for 30 days
    // Removed notificationService.cleanupOldNotifications(30);
  } catch (error) {
    console.error('Error cleaning up old notifications:', error);
  }
}); 