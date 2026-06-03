---
layout: page
title: Поддержать Hestia
---

<script setup>
import CopyToClipboardInput from './.vitepress/theme/components/CopyToClipboardInput.vue';
</script>
<div class="donation-header">
  <h2>Поддержите проект Hestia</h2><br>
  <p class="subtitle">
    Ваша поддержка будет напрямую направлена на обслуживание серверов Hestia,<br>
    разработку новых функций и оптимизацию сервисов,<br>
    помогая создать более стабильную и надёжную панель управления.
  </p>
</div>
<div class="table-container">
  <table>
    <thead>
      <tr>
        <th>Способ поддержки</th>
        <th>Аккаунт / Действие</th>
        <th>Примечание</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td class="method-name" data-th="Способ поддержки">PayPal</td>
        <td class="text-center" data-th="Аккаунт / Действие">
          <a
            href="https://www.paypal.com/donate/?hosted_button_id=ST87LQH2CHGLA"
            target="_blank"
            class="paypal-button">
            <span class="paypal-logo">
              <img src="/paypal.svg" alt="PayPal Logo" class="paypal-svg">
            </span>
            <span class="button-text">Поддержать сейчас</span>
          </a>
        </td>
        <td class="text-center" data-th="Примечание">Поддержка кредитными/дебетовыми картами</td>
      </tr>
      <tr>
        <td class="method-name" data-th="Способ поддержки">Bitcoin</td>
        <td class="text-center" data-th="Аккаунт / Действие"><CopyToClipboardInput value="bc1q48jt5wg5jaj8g9zy7c3j03cv57j2m2u5anlutu" class="crypto-address" /></td>
        <td class="text-center" data-th="Примечание">Основная сеть Bitcoin</td>
      </tr>
      <tr>
        <td class="method-name" data-th="Способ поддержки">Ethereum</td>
        <td class="text-center" data-th="Аккаунт / Действие"><CopyToClipboardInput value="0xfF3Dd2c889bd0Ff73d8085B84A314FC7c88e5D51" class="crypto-address" /></td>
        <td class="text-center" data-th="Примечание">Сеть ERC20</td>
      </tr>
      <tr class="deprecated-row">
        <td class="method-name deprecated-text" data-th="Способ поддержки">Binance</td>
        <td class="text-center" data-th="Аккаунт / Действие"><CopyToClipboardInput value="bnb1l4ywvw5ejfmsgjdcx8jn5lxj7zsun8ktfu7rh8" class="crypto-address deprecated-input" /></td>
        <td class="text-center danger-alert" data-th="Примечание">
          <strong>⚠️ Крайне опасно!</strong> Сеть BEP2 полностью прекратила работу в конце 2024 года! Не отправляйте средства, иначе они будут потеряны навсегда.
        </td>
      </tr>
      <tr>
        <td class="method-name" data-th="Способ поддержки">BNB Smart Chain</td>
        <td class="text-center" data-th="Аккаунт / Действие"><CopyToClipboardInput value="0xfF3Dd2c889bd0Ff73d8085B84A314FC7c88e5D51" class="crypto-address" /></td>
        <td class="text-center warning" data-th="Примечание">Убедитесь, что используете сеть BSC (BEP20)</td>
      </tr>
      <tr>
        <td class="method-name" data-th="Способ поддержки">Monero (XMR)</td>
        <td class="text-center" data-th="Аккаунт / Действие"><CopyToClipboardInput value="45p5eKWfp3kYcY3cBtKq2TWpp5HGYFAbre2Xd76sRhWGXfahAj5MkxzV2oPF2VqU617pwS5JZh1h4gy6jTm73vE7PnQ48Rs" class="crypto-address" /></td>
        <td class="text-center" data-th="Примечание">Конфиденциальная сеть</td>
      </tr>
    </tbody>
  </table>
</div>

<div class="donation-footer">
  <h3 class="text-center">Искренне благодарим вас за поддержку!</h3><br>

  <p class="text-center">Каждое пожертвование — это огромное вдохновение для разработки Hestia.<span class="mobile-line-break"></span> Мы будем неустанно работать, чтобы улучшить качество использования панели управления!</p>
  
  <div class="notice-box">
    <h4 class="text-center">
      <span class="warning-icon"></span>
      Важное примечание
    </h4>
    <ul>
      <li>✅ Перед переводом <strong>внимательно проверьте</strong> адрес блокчейна</li>
      <li>⏳ Перевод криптовалюты обычно требует от 1 до 30 минут для подтверждения</li>
      <span class="mobile-br"><li>📧 Если у вас есть вопросы, пожалуйста, свяжитесь с нами по электронной почте!<br class="mobile-only"><a href="mailto:info@hestiacp.com">info@hestiacp.com</a></li></span>
    </ul>
  </div>
</div>

<style scoped>
.crypto-address {
  font-family: monospace;
  font-size: 18px;
  color: #333;
}
.CopyToClipboardInput {
  gap: 8px;
  background: var(--vp-c-bg);
  border-radius: 4px;
  padding: 2px;
}
@keyframes pulse {
  0% { opacity: 1 }
  50% { opacity: 0.5 }
  100% { opacity: 1 }
}
.donation-header h2 {
  font-size: 2.5rem;
  font-weight: 700;
  color: var(--vp-c-brand);
  margin-bottom: 1.2rem;
  position: relative;
  display: inline-block;
  letter-spacing: -0.03em;
  padding-top: 1rem;
  transform: translateY(15px);
}
.donation-header h2::after {
  content: '';
  position: absolute;
  bottom: -8px;
  left: 50%;
  transform: translateX(-50%);
  width: 60%;
  height: 3px;
  background: linear-gradient(90deg, var(--vp-c-brand) 0%, rgba(0,0,0,0) 100%);
  opacity: 0.6;
  transition: all 0.3s ease;
}
.donation-header h2:hover::after {
  width: 80%;
  opacity: 1;
}
.table-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1rem;
}
th:nth-child(2),
td:nth-child(2) {
  width: 50%;
}
.table-container table {
  width: 100%;
  border-collapse: collapse;
}

.table-container td {
  border: 1px solid #ddd;
  padding: 10px;
  text-align: center;
}

.paypal-button {
  background-color: var(--vp-button-brand-bg);
  color: white !important;
  padding: 10px 20px;
  text-decoration: none;
  border-radius: 5px;
  transition: background-color 0.3s;
}

.paypal-button:hover {
  background-color: #9a1d5a;
}

.paypal-svg {
  vertical-align: middle;
  margin-right: 1px;
}
.warning {
  color: #d32f2f;
  font-weight: bold;
}

.paypal-button {
  display: inline-flex;
  align-items: center;
  padding: 12px 24px;
  border-radius: 24px;
  background: var(--vp-c-brand);
  color: white !important;
  text-decoration: none;
  transition: all 0.3s ease;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  border: 1px solid var(--vp-c-brand-dark);
}
.paypal-button:hover {
  background: #dd0b71;
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0,0,0,0.2);
}
.paypal-logo {
  display: flex;
  margin-right: 12px;
}
.paypal-logo svg {
  width: 24px;
  height: 24px;
}
.button-text {
  font-weight: 600;
  font-size: 16px;
}
.donation-header {
  text-align: center;
  margin-bottom: 2.5rem;
}
.subtitle {
  color: var(--vp-c-text-2);
  margin-top: 0.8rem;
}
table {
  width: 100%;
  border-collapse: collapse;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  border-radius: 8px;
  overflow: hidden;
}
th {
  background-color: var(--vp-c-brand);
  color: white;
  padding: 1.2rem;
  text-align: center;
}
td {
  padding: 1rem;
  background-color: var(--vp-c-bg-soft);
  border-bottom: 1px solid var(--vp-c-divider);
}
.method-name {
  font-weight: 600;
  color: var(--vp-c-brand);
}
.text-center {
  text-align: center !important;
}
.warning {
  color: #ff4d4f;
  font-weight: 500;
}
.donation-footer {
  max-width: 800px;
  margin: 3rem auto;
  text-align: center;
}
.notice-box {
  background: #fff9e6;
  border-radius: 8px;
  padding: 1.5rem 2rem;
  margin-top: 2rem;
  border-left: 4px solid #ffd700;
  box-shadow: 0 2px 8px rgba(255, 193, 7, 0.1);
  position: relative;
  overflow: hidden;
}
.notice-box::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  width: 40px;
  height: 100%;
  background: rgba(255, 193, 7, 0.1);
}
.notice-box h4 {
  color: #d32f2f;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-size: 1.1em;
  margin-bottom: 1rem;
}
.notice-box ul {
  list-style: none;
  padding: 0;
  margin: 1rem 0;
}
.notice-box li {
  margin: 0.8rem 0;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
}
.paypal-svg {
  width: 24px;
  height: 24px;
  color: currentColor;
}
.paypal-button:hover .paypal-svg {
  filter: brightness(1.2);
}
.notice-box h4::before {
  content: '';
  display: inline-block;
  width: 24px;
  height: 24px;
  background: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="%23d32f2f"><path d="M12 2L1 21h22L12 2zm0 4.5l7.53 13h-15.06L12 6.5zM13 16h-2v2h2v-2zm-2-6h2v4h-2v-4z"/></svg>');
  animation: pulse 1.5s infinite;
}
.notice-box a {
  color: var(--vp-c-brand);
  text-decoration: none;
  transition: color 0.3s ease;
}
.notice-box a:hover {
  color: var(--vp-c-brand-2);
}
.notice-box {
  background: #fff9e6;
  border-radius: 8px;
  padding: 1.5rem 2rem;
  margin-top: 2rem;
  border-left: 4px solid #ffd700;
  box-shadow: 0 2px 8px rgba(255, 193, 7, 0.1);
  position: relative;
  overflow: hidden;
}

.notice-box::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  width: 40px;
  height: 100%;
  background: rgba(255, 193, 7, 0.1);
}

.notice-box h4 {
  color: #d32f2f;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-size: 1.1em;
  margin-bottom: 1rem;
}

.notice-box ul {
  list-style: none;
  padding: 0;
  margin: 1rem 0;
}

.notice-box li {
  margin: 0.8rem 0;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
}

.notice-box a {
  color: var(--vp-c-brand);
  text-decoration: none;
  transition: color 0.3s ease;
}

.notice-box a:hover {
  color: var(--vp-c-brand-2);
}

.dark .table-container .crypto-address {
  color: var(--vp-c-text);
}

.dark .table-container .CopyToClipboardInput input {
  background-color: var(--vp-c-bg-alt);
  color: var(--vp-c-text);
  border: 1px solid var(--vp-c-border);
}
.dark .notice-box {
  background: var(--vp-c-bg-alt);
  border-left: 4px solid #ff9800;
  box-shadow: 0 2px 8px rgba(255, 152, 0, 0.1);
}

.dark .notice-box::before {
  background: rgba(255, 152, 0, 0.1);
}

.dark .notice-box h4 {
  color: var(--vp-c-text);
}

.dark .notice-box a {
  color: var(--vp-c-brand);
}
@media (max-width: 768px) {
  .table-container {
    max-width: 100%;
    padding: 10px;
  }
  
  table {
    width: 100%;
    min-width: auto;
  }
  
  th:nth-child(2),
  td:nth-child(2) {
    width: 100%;
    display: block;
  }
}
@media (max-width: 640px) {
  .notice-box {
    padding: 1rem;
    margin-top: 1.5rem;
  }

  .notice-box h4 {
    font-size: 1rem;
  }

  .notice-box li {
    font-size: 0.9rem;
    margin: 0.6rem 0;
  }
}

@media (max-width: 375px) {
  .notice-box {
    padding: 0.8rem;
  }

  .notice-box h4 {
    font-size: 0.9rem;
  }

  .notice-box li {
    font-size: 0.8rem;
    margin: 0.5rem 0;
  }
}
@media (max-width: 640px) {
  .donation-header h2 {
    font-size: 2rem;
    line-height: 1.3;
    margin-bottom: 1rem;
    transform: none;
    padding-top: 0.5rem;
    letter-spacing: -0.02em;
  }
  .donation-header h2::after {
    width: 50%;
    bottom: -6px;
    height: 2px;
  }
  .donation-header h2:hover::after {
    width: 60%;
  }
}
@media (max-width: 375px) {
  .donation-header h2 {
    font-size: 1.8rem;
    margin-bottom: 0.8rem;
  }
  .donation-header h2::after {
    width: 45%;
  }
}
@media (max-width: 640px) {
  table, thead, tbody, th, td, tr {
    display: block;
    width: 100%;
  }
  thead tr {
    position: absolute;
    top: -9999px;
    left: -9999px;
  }
  tr {
    margin: 0 0 1.5rem;
    padding: 1.5rem 1rem;
    background: var(--vp-c-bg-soft);
    border-radius: 8px;
    box-shadow: 0 2px 12px rgba(0,0,0,0.1);
  }
  td {
    position: relative;
    padding: 1rem 0.5rem !important;
    text-align: center !important;
    border: none !important;
    display: flex !important;
    flex-direction: column;
    align-items: center;
  }
  td:not(:first-child)::before {
    content: attr(data-th) "：";
    display: block;
    font-size: 0.9rem;
    color: var(--vp-c-brand);
    margin-bottom: 0.8rem;
    font-weight: 600;
    letter-spacing: 0.5px;
    opacity: 0.9;
  }
  td.method-name {
    font-size: 1.1rem;
    padding-bottom: 1.2rem !important;
    border-bottom: 2px solid var(--vp-c-divider) !important;
    margin-bottom: 1rem;
  }
  .paypal-button {
    width: 100%;
    max-width: 150px;
    margin: 0.5rem auto;
    padding: 12px !important;
  }
  .CopyToClipboardInput input {
    font-size: 0.9rem;
    padding: 10px 15px;
    min-width: 240px;
  }
}
@media (max-width: 375px) {
  .CopyToClipboardInput input {
    font-size: 0.85rem;
    padding: 8px 12px;
  }
  td:not(:first-child)::before {
    font-size: 0.8rem;
  }
}
.deprecated-row {
  background-color: #f8f9fa;
  opacity: 0.7;
}

.deprecated-text {
  text-decoration: line-through;
  color: #6c757d;
}
.danger-alert {
  color: #dc3545;
  font-weight: bold;
  background-color: #f8d7da;
}
</style>
