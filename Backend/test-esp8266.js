// Test script to simulate ESP8266 sending data
// Run this to see real-time updates in the dashboard

const sendReading = async () => {
  const reading = {
    temp: (20 + Math.random() * 10).toFixed(1),
    humidity: (50 + Math.random() * 30).toFixed(1),
    moisture: Math.floor(300 + Math.random() * 200)
  };

  try {
    const response = await fetch('http://localhost:3000/api/data', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(reading)
    });

    if (response.ok) {
      console.log('✅ Sent reading:', reading);
    } else {
      console.error('❌ Failed to send reading:', response.status);
    }
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
};

console.log('🌱 ESP8266 Simulator Started');
console.log('📡 Sending sensor readings every 3 seconds...');
console.log('👀 Watch your dashboard update in real-time!\n');

// Send initial reading
sendReading();

// Send a reading every 3 seconds
setInterval(sendReading, 3000);
