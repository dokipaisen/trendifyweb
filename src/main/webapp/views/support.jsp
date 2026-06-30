<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="layout/header.jsp">
    <jsp:param name="pageTitle" value="Trendify - Trung Tâm Trợ Giúp" />
</jsp:include>

<main>
    <div style="display: flex; gap: 50px; flex-wrap: wrap;">
        <!-- Left: FAQs Collapsible Accordion -->
        <div style="flex: 1; min-width: 350px;">
            <h2 class="section-title" style="margin-bottom: 25px;">Câu Hỏi Thường Gặp</h2>

            <div class="faq-item">
                <div class="faq-question" onclick="toggleFaq(this)">
                    <span>Thời gian giao hàng mất bao lâu?</span>
                    <span>+</span>
                </div>
                <div class="faq-answer">
                    Thời gian giao hàng nội thành Hà Nội và TP.HCM sẽ mất từ 1 - 2 ngày làm việc. Các khu vực tỉnh thành khác sẽ từ 3 - 5 ngày làm việc (không kể Chủ Nhật và ngày lễ).
                </div>
            </div>

            <div class="faq-item">
                <div class="faq-question" onclick="toggleFaq(this)">
                    <span>Chính sách đổi trả sản phẩm như thế nào?</span>
                    <span>+</span>
                </div>
                <div class="faq-answer">
                    Trendify hỗ trợ đổi trả hàng trong vòng 7 ngày kể từ ngày nhận hàng. Sản phẩm phải còn nguyên tem mác, chưa qua sử dụng, giặt ủi và không bị hư hỏng bởi các tác nhân bên ngoài.
                </div>
            </div>

            <div class="faq-item">
                <div class="faq-question" onclick="toggleFaq(this)">
                    <span>Làm sao để chọn đúng size quần áo?</span>
                    <span>+</span>
                </div>
                <div class="faq-answer">
                    Mỗi sản phẩm tại Trendify đều có bảng thông số size chi tiết ở phần mô tả. Bạn có thể tham khảo số đo chiều cao và cân nặng phù hợp. Nếu cần tư vấn thêm, hãy chat ngay với hệ thống hỗ trợ trực tuyến ở bên cạnh.
                </div>
            </div>

            <div class="faq-item">
                <div class="faq-question" onclick="toggleFaq(this)">
                    <span>Tôi có thể thay đổi phương thức thanh toán không?</span>
                    <span>+</span>
                </div>
                <div class="faq-answer">
                    Đối với các đơn hàng đang ở trạng thái "Chờ xác nhận", bạn có thể liên hệ với tổng đài hỗ trợ để nhờ thay đổi thông tin thanh toán hoặc yêu cầu hủy để đặt lại đơn hàng mới.
                </div>
            </div>
        </div>

        <!-- Right: Automated Chat Support -->
        <div style="flex: 1; min-width: 350px; display: flex; flex-direction: column;">
            <h2 class="section-title" style="margin-bottom: 25px;">Chat Hỗ Trợ Trực Tuyến</h2>

            <div style="border: 1px solid var(--border-color-dark); display: flex; flex-direction: column; height: 480px; background-color: var(--bg-secondary);">
                <!-- Chat Log Header -->
                <div style="background-color: var(--bg-dark); color: var(--text-light); padding: 15px; font-size: 13px; font-weight: 700; text-transform: uppercase;">
                    Trợ lý tự động - Trendify Bot
                </div>

                <!-- Chat message logs -->
                <div id="chatMessages" style="flex-grow: 1; padding: 20px; overflow-y: auto; display: flex; flex-direction: column; gap: 15px;">
                    <div style="align-self: flex-start; background-color: var(--bg-primary); border: 1px solid var(--border-color); padding: 10px 15px; font-size: 13px; max-width: 80%;">
                        Xin chào! Tôi là trợ lý tự động của Trendify. Tôi có thể giúp gì cho bạn hôm nay? (Bạn có thể hỏi về: size, giao hàng, đổi trả)
                    </div>
                </div>

                <!-- Suggestion Chips Container -->
                <div id="suggestionChips" style="display: flex; gap: 8px; padding: 10px; flex-wrap: wrap; background-color: var(--bg-secondary); border-top: 1px solid var(--border-color); justify-content: flex-start;">
                    <button type="button" onclick="clickSuggestion('Tính size nhanh')" style="background-color: var(--bg-primary); border: 1px solid var(--border-color); padding: 6px 12px; border-radius: 16px; font-size: 11px; font-weight: 600; cursor: pointer; transition: var(--transition);">Tính size nhanh</button>
                    <button type="button" onclick="clickSuggestion('Thời gian giao hàng')" style="background-color: var(--bg-primary); border: 1px solid var(--border-color); padding: 6px 12px; border-radius: 16px; font-size: 11px; font-weight: 600; cursor: pointer; transition: var(--transition);">Thời gian giao hàng</button>
                    <button type="button" onclick="clickSuggestion('Chính sách đổi trả')" style="background-color: var(--bg-primary); border: 1px solid var(--border-color); padding: 6px 12px; border-radius: 16px; font-size: 11px; font-weight: 600; cursor: pointer; transition: var(--transition);">Chính sách đổi trả</button>
                </div>

                <!-- Chat Input Form -->
                <form id="chatForm" onsubmit="sendMessage(event)" style="display: flex; border-top: 1px solid var(--border-color-dark); padding: 10px; gap: 10px; background-color: var(--bg-primary);">
                    <input type="text" id="chatInput" placeholder="Nhập tin nhắn của bạn..." required style="flex-grow: 1; padding: 10px; border: 1px solid var(--border-color);">
                    <button type="submit" class="btn btn-dark" style="padding: 10px 20px;">Gửi</button>
                </form>
            </div>
        </div>
    </div>
</main>

<script>
    function toggleFaq(element) {
        const answer = element.nextElementSibling;
        const symbol = element.querySelector("span:last-child");
        
        if (answer.style.display === "block") {
            answer.style.display = "none";
            symbol.innerText = "+";
        } else {
            answer.style.display = "block";
            symbol.innerText = "-";
        }
    }

    function clickSuggestion(text) {
        appendMessage(text, "user");
        setTimeout(() => {
            processBotReply(text);
        }, 500);
    }

    function sendMessage(e) {
        e.preventDefault();
        const input = document.getElementById("chatInput");
        const msgText = input.value.trim();
        if (!msgText) return;

        appendMessage(msgText, "user");
        input.value = "";

        setTimeout(() => {
            processBotReply(msgText);
        }, 800);
    }

    function processBotReply(msgText) {
        let reply = "Xin lỗi, tôi chưa hiểu câu hỏi của bạn. Vui lòng liên hệ số hotline 1900 6066 để được nhân viên hỗ trợ trực tiếp.";
        const lowerMsg = msgText.toLowerCase();

        if (lowerMsg.includes("size") || lowerMsg.includes("kich thuoc") || lowerMsg.includes("chiều cao") || lowerMsg.includes("cân nặng") || lowerMsg.includes("chieu cao") || lowerMsg.includes("can nang") || lowerMsg.includes("tinh size")) {
            appendMessage("Để chọn đúng size, bạn hãy tham khảo bảng thông số ở trang chi tiết của sản phẩm đó. Hoặc bạn có thể tự động tính toán size phù hợp bằng công cụ bên dưới:", "bot");
            
            const formHtml = `
                <div class="chat-form-bubble" style="background-color: var(--primary-light); border: 1px solid var(--border-color-dark); padding: 15px; border-radius: 8px; width: 100%; max-width: 280px; margin-top: 5px; font-family: var(--font-sans);">
                    <p style="font-weight: 700; margin-bottom: 10px; font-size: 13px; color: var(--primary-color);">Tính Size Tự Động</p>
                    <div style="display: flex; flex-direction: column; gap: 8px; margin-bottom: 12px;">
                        <div style="display: flex; flex-direction: column; gap: 4px;">
                            <label style="font-size: 11px; font-weight: 600; text-transform: uppercase; color: var(--text-secondary); text-align: left; display: block;">Chiều cao (cm):</label>
                            <input type="number" class="botHeightInput" placeholder="Ví dụ: 170" min="100" max="250" style="padding: 6px 10px; border-radius: 4px; border: 1px solid var(--border-color); font-size: 13px; width: 100%; box-sizing: border-box;">
                        </div>
                        <div style="display: flex; flex-direction: column; gap: 4px;">
                            <label style="font-size: 11px; font-weight: 600; text-transform: uppercase; color: var(--text-secondary); text-align: left; display: block;">Cân nặng (kg):</label>
                            <input type="number" class="botWeightInput" placeholder="Ví dụ: 65" min="30" max="150" style="padding: 6px 10px; border-radius: 4px; border: 1px solid var(--border-color); font-size: 13px; width: 100%; box-sizing: border-box;">
                        </div>
                    </div>
                    <button type="button" onclick="submitBotSizeForm(this)" class="btn btn-dark" style="width: 100%; padding: 8px; font-size: 12px; border-radius: 4px; background-color: var(--primary-color); border-color: var(--primary-color); color: white;">Tính Size Của Tôi</button>
                </div>
            `;
            appendHtmlMessage(formHtml, "bot");
            return;
        } else if (lowerMsg.includes("ship") || lowerMsg.includes("giao hàng") || lowerMsg.includes("vận chuyển") || lowerMsg.includes("bao lâu") || lowerMsg.includes("giao hang") || lowerMsg.includes("van chuyen") || lowerMsg.includes("bao lau")) {
            reply = "Trendify miễn phí vận chuyển cho tất cả đơn hàng. Thời gian giao hàng khoảng 1-2 ngày đối với Hà Nội/TP.HCM, và 3-5 ngày đối với các tỉnh thành khác.";
        } else if (lowerMsg.includes("đổi trả") || lowerMsg.includes("trả hàng") || lowerMsg.includes("hoàn tiền") || lowerMsg.includes("đổi size") || lowerMsg.includes("doi tra") || lowerMsg.includes("tra hang") || lowerMsg.includes("hoan tien") || lowerMsg.includes("doi size")) {
            reply = "Chúng tôi hỗ trợ đổi trả miễn phí trong 7 ngày kể từ khi nhận hàng với sản phẩm còn nguyên tem mác và chưa qua giặt ủi.";
        } else if (lowerMsg.includes("chào") || lowerMsg.includes("chao") || lowerMsg.includes("hello") || lowerMsg.includes("hi")) {
            reply = "Xin chào! Tôi có thể giúp bạn giải đáp thông tin về: chọn size, chính sách vận chuyển/giao hàng, hoặc quy trình đổi trả sản phẩm.";
        }

        appendMessage(reply, "bot");
    }

    function getRecommendedSize(height, weight) {
        if (isNaN(height) || isNaN(weight)) return null;
        
        if (weight < 40) return { size: "XS", fitAdvice: "Dành cho người có cân nặng dưới 45kg." };
        if (weight > 95) return { size: "XXXL", fitAdvice: "Vượt quá bảng kích cỡ tiêu chuẩn, vui lòng liên hệ hotline 1900 6066 để được đặt may riêng." };
        
        let size = "";
        if (weight >= 40 && weight < 50) {
            size = (height < 155) ? "S" : "XS";
        } else if (weight >= 50 && weight < 58) {
            size = (height < 162) ? "M" : "S";
        } else if (weight >= 58 && weight < 66) {
            size = (height < 169) ? "L" : "M";
        } else if (weight >= 66 && weight < 75) {
            size = (height < 176) ? "XL" : "L";
        } else if (weight >= 75 && weight < 85) {
            size = (height < 182) ? "XXL" : "XL";
        } else {
            size = "XXL";
        }
        
        let fitAdvice = "";
        if (size === "S") fitAdvice = "Phù hợp cho chiều cao 1m50 - 1m60 và cân nặng 45kg - 52kg.";
        else if (size === "M") fitAdvice = "Phù hợp cho chiều cao 1m60 - 1m67 và cân nặng 53kg - 61kg.";
        else if (size === "L") fitAdvice = "Phù hợp cho chiều cao 1m67 - 1m74 và cân nặng 62kg - 70kg.";
        else if (size === "XL") fitAdvice = "Phù hợp cho chiều cao 1m74 - 1m81 và cân nặng 71kg - 79kg.";
        else if (size === "XXL") fitAdvice = "Phù hợp cho chiều cao 1m81 - 1m88 và cân nặng 80kg - 90kg.";
        
        return { size, fitAdvice };
    }

    function submitBotSizeForm(btn) {
        const container = btn.closest(".chat-form-bubble");
        const heightInput = container.querySelector(".botHeightInput");
        const weightInput = container.querySelector(".botWeightInput");
        
        const h = parseInt(heightInput.value);
        const w = parseInt(weightInput.value);
        
        if (!h || !w || h <= 0 || w <= 0) {
            alert("Vui lòng nhập đầy đủ chiều cao và cân nặng!");
            return;
        }
        
        heightInput.disabled = true;
        weightInput.disabled = true;
        btn.disabled = true;
        btn.innerText = "Đã Tính Toán";
        
        appendMessage("Tôi cao " + h + "cm, nặng " + w + "kg.", "user");
        
        setTimeout(() => {
            const res = getRecommendedSize(h, w);
            let botReply = "";
            if (res) {
                botReply = "Dựa trên chiều cao " + h + "cm và cân nặng " + w + "kg, size phù hợp nhất cho bạn là size " + res.size + ". (" + res.fitAdvice + ") Nếu muốn mặc rộng rãi thoải mái, bạn có thể chọn lớn hơn 1 size.";
            } else {
                botReply = "Xin lỗi, tôi không thể tính được size với thông số này. Bạn vui lòng liên hệ hotline 1900 6066 để được nhân viên tư vấn trực tiếp.";
            }
            appendMessage(botReply, "bot");
        }, 600);
    }

    function appendMessage(text, sender) {
        const chatArea = document.getElementById("chatMessages");
        const msgDiv = document.createElement("div");
        
        if (sender === "user") {
            msgDiv.style.alignSelf = "flex-end";
            msgDiv.style.backgroundColor = "var(--bg-dark)";
            msgDiv.style.color = "var(--text-light)";
            msgDiv.style.border = "1px solid var(--bg-dark)";
        } else {
            msgDiv.style.alignSelf = "flex-start";
            msgDiv.style.backgroundColor = "var(--bg-primary)";
            msgDiv.style.border = "1px solid var(--border-color)";
        }

        msgDiv.style.padding = "10px 15px";
        msgDiv.style.fontSize = "13px";
        msgDiv.style.maxWidth = "80%";
        msgDiv.innerText = text;

        chatArea.appendChild(msgDiv);
        chatArea.scrollTop = chatArea.scrollHeight;
    }

    function appendHtmlMessage(htmlContent, sender) {
        const chatArea = document.getElementById("chatMessages");
        const msgDiv = document.createElement("div");
        
        if (sender === "user") {
            msgDiv.style.alignSelf = "flex-end";
            msgDiv.style.backgroundColor = "var(--bg-dark)";
            msgDiv.style.color = "var(--text-light)";
            msgDiv.style.border = "1px solid var(--bg-dark)";
        } else {
            msgDiv.style.alignSelf = "flex-start";
            msgDiv.style.backgroundColor = "var(--bg-primary)";
            msgDiv.style.border = "1px solid var(--border-color)";
        }

        msgDiv.style.padding = "10px 15px";
        msgDiv.style.fontSize = "13px";
        msgDiv.style.maxWidth = "80%";
        msgDiv.innerHTML = htmlContent;

        chatArea.appendChild(msgDiv);
        chatArea.scrollTop = chatArea.scrollHeight;
    }
</script>

<jsp:include page="layout/footer.jsp" />
