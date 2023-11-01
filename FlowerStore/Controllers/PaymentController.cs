using FlowerStore.Config;
using FlowerStore.Extensions;
using FlowerStore.Models;
using Newtonsoft.Json.Linq;
using PayPal.Api;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;

namespace FlowerStore.Controllers
{
    public class PaymentController : Controller
    {
        ShoppingEntities db = new ShoppingEntities();
        // GET: Payment
        public ActionResult PaymentWithPaypal(string Cancel = null)
        {
            //getting the apiContext  
            APIContext apiContext = PaypalConfiguration.GetAPIContext();
            try
            {
                //A resource representing a Payer that funds a payment Payment Method as paypal  
                //Payer Id will be returned when payment proceeds or click to pay  
                string payerId = Request.Params["PayerID"];
                if (string.IsNullOrEmpty(payerId))
                {
                    //this section will be executed first because PayerID doesn't exist  
                    //it is returned by the create function call of the payment class  
                    // Creating a payment  
                    // baseURL is the url on which paypal sendsback the data.  
                    string baseURI = Request.Url.Scheme + "://" + Request.Url.Authority + "/Payment/PaymentWithPayPal?";
                    //here we are generating guid for storing the paymentID received in session  
                    //which will be used in the payment execution  
                    var guid = Convert.ToString((new Random()).Next(100000));
                    //CreatePayment function gives us the payment approval url  
                    //on which payer is redirected for paypal account payment  
                    var createdPayment = this.CreatePayment(apiContext, baseURI + "guid=" + guid);
                    //get links returned from paypal in response to Create function call  
                    var links = createdPayment.links.GetEnumerator();
                    string paypalRedirectUrl = null;
                    while (links.MoveNext())
                    {
                        Links lnk = links.Current;
                        if (lnk.rel.ToLower().Trim().Equals("approval_url"))
                        {
                            //saving the payapalredirect URL to which user will be redirected for payment  
                            paypalRedirectUrl = lnk.href;
                        }
                    }
                    // saving the paymentID in the key guid  
                    Session.Add(guid, createdPayment.id);
                    return Redirect(paypalRedirectUrl);
                }
                else
                {
                    // This function exectues after receving all parameters for the payment  
                    var guid = Request.Params["guid"];
                    var executedPayment = ExecutePayment(apiContext, payerId, Session[guid] as string);
                    //If executed payment failed then we will show payment failure message to user  
                    if (executedPayment.state.ToLower() != "approved")
                    {
                        return RedirectToAction("Message", "Cart", new { mess = "Lỗi" });
                    }
                }
            }
            catch (Exception ex)
            {
                return RedirectToAction("Message", "Cart", new
                {
                    mess = ex.Message
                });
            }
            Session.Remove("Cart");
            //update paid
            Models.Order order = db.Orders.Find(Convert.ToInt32(Session["OrderId"]));
            order.IsPaid = true;
            db.SaveChanges();
            return RedirectToAction("Message", "Cart", new { mess = "Đặt hàng và thanh toán thành công" });
        }

        private PayPal.Api.Payment payment;


        private Payment ExecutePayment(APIContext apiContext, string payerId, string paymentId)
        {
            var paymentExecution = new PaymentExecution()
            {
                payer_id = payerId
            };
            this.payment = new Payment()
            {
                id = paymentId
            };
            return this.payment.Execute(apiContext, paymentExecution);
        }

        private Payment CreatePayment(APIContext apicontext, string redirectURl)
        {
            var itemList = new ItemList()
            {
                items = new List<Item>()
            };

            if (Session["Cart"] != null)
            {
                var d = GetCurrencyExchange("VND", "USD");
                List<ItemCart> cart = (List<ItemCart>)Session["Cart"];
                foreach (var item in cart)
                {
                    decimal p = Math.Round(item.ProductPrice * d, 0);
                    itemList.items.Add(new Item()
                    {
                        name = item.ProductName,
                        currency = "USD",
                        price = p.ToString(),
                        quantity = item.Quantity.ToString(),
                        sku = "sku"
                    });
                }

                var payer = new Payer()
                {
                    payment_method = "paypal"
                };

                var redirUrl = new RedirectUrls()
                {
                    cancel_url = redirectURl + "&Cancel=true",
                    return_url = redirectURl
                };

                var details = new Details()
                {
                    tax = "0",
                    shipping = "0",
                    subtotal = itemList.items.Sum(x => int.Parse(x.price) * int.Parse(x.quantity)).ToString()
                };

                var amount = new Amount()
                {
                    currency = "USD",
                    total = details.subtotal,
                    details = details
                };

                var transactionList = new List<Transaction>();
                transactionList.Add(new Transaction()
                {
                    description = "Transaction Description",
                    invoice_number = Convert.ToString((new Random()).Next(100000)),
                    amount = amount,
                    item_list = itemList
                });

                this.payment = new Payment()
                {
                    intent = "sale",
                    payer = payer,
                    transactions = transactionList,
                    redirect_urls = redirUrl
                };
            }

            return this.payment.Create(apicontext);
        }

        public Decimal GetCurrencyExchange(String localCurrency, String foreignCurrency)
        {
            var code = $"{localCurrency}_{foreignCurrency}";
            var newRate = FetchSerializedData(code);
            return newRate;
        }

        private Decimal FetchSerializedData(String code)
        {
            var url = "https://free.currconv.com/api/v7/convert?q=" + code + "&compact=y&apiKey=7cf3529b5d3edf9fa798";
            var webClient = new WebClient();
            var jsonData = String.Empty;

            var conversionRate = 1.0m;
            try
            {
                jsonData = webClient.DownloadString(url);
                var jsonObject = new JavaScriptSerializer().Deserialize<Dictionary<string, Dictionary<string, decimal>>>(jsonData);
                var result = jsonObject[code];
                conversionRate = result["val"];

            }
            catch (Exception) { }

            return conversionRate;
        }
        public ActionResult PaymentWithMomo()
        {
            List<ItemCart> cart = (List<ItemCart>)Session["Cart"];
            string endpoint = ConfigurationManager.AppSettings["endpoint"].ToString();
            string partnerCode = ConfigurationManager.AppSettings["partnerCode"].ToString();
            string accessKey = ConfigurationManager.AppSettings["accessKey"].ToString();
            string serectKey = ConfigurationManager.AppSettings["serectKey"].ToString();
            string orderInfo = "DH" + DateTime.Now.ToString("yyyyMMddHHmmss");
            string returnUrl = ConfigurationManager.AppSettings["returnUrl"].ToString();
            string notifyUrl = ConfigurationManager.AppSettings["notifyUrl"].ToString();

            string amount = Convert.ToInt32(cart.Sum(x => x.ProductPrice * x.Quantity)).ToString();
            string orderid = Guid.NewGuid().ToString();
            string requestId = Guid.NewGuid().ToString();
            string extraData = "";

            string rawHash = "partnerCode=" + partnerCode
                + "&accessKey=" + accessKey
                + "&requestId=" + requestId
                + "&amount=" + amount
                + "&orderId=" + orderid
                + "&orderInfo=" + orderInfo
                + "&returnUrl=" + returnUrl
                + "&notifyUrl=" + notifyUrl
                + "&extraData=" + extraData;
            MoMoSecurity crypto = new MoMoSecurity();
            string signature = crypto.signSHA256(rawHash, serectKey);
            JObject message = new JObject
            {
                {"partnerCode",partnerCode },
                {"accessKey",accessKey },
                {"requestId",requestId },
                {"amount",amount },
                {"orderId",orderid },
                {"orderInfo",orderInfo },
                {"returnUrl",returnUrl },
                {"notifyUrl",notifyUrl },
                {"requestType","captureMoMoWallet" },
                {"signature",signature }
            };
            string responseFromMomo = PaymentRequest.sendPaymentRequest(endpoint, message.ToString());
            JObject jmessage = JObject.Parse(responseFromMomo);
            return Redirect(jmessage.GetValue("payUrl").ToString());
        }

        public ActionResult ReturnUrl()
        {
            string param = Request.QueryString.ToString().Substring(0, Request.QueryString.ToString().IndexOf("signature") - 1);
            param = Server.UrlDecode(param);
            MoMoSecurity crypto = new MoMoSecurity();
            string serectKey = ConfigurationManager.AppSettings["serectKey"].ToString();
            string signature = crypto.signSHA256(param, serectKey);
            if (signature != Request["signature"].ToString())
            {
                ViewBag.message = "Thông tin request không hợp lệ";
            }
            else if (!Request.QueryString["errorCode"].Equals("0"))
            {
                ViewBag.message = "Thanh toán thất bại";
            }
            else
            {
                Session.Remove("Cart");
                //update paid
                Models.Order order = db.Orders.Find(Convert.ToInt32(Session["OrderId"]));
                order.IsPaid = true;
                db.SaveChanges();
                Session.Remove("OrderID");
                ViewBag.message = "Thanh toán thành công";
            }
            return View();
        }

        public JsonResult NotifyUrl()
        {
            string param = "";
            param = "partner_code=" + Request["partner_code"]
                + "&access_key=" + Request["access_key"]
                + "&amount=" + Request["amount"]
                + "&order_id=" + Request["order_id"]
                + "&order_info=" + Request["orderInfo"]
                + "&order_type=" + Request["order_type"]
                + "&transaction_id=" + Request["transaction_id"]
                + "&message=" + Request["message"]
                + "&response_time=" + Request["response_time"]
                + "&status_code=" + Request["status_code"];
            param = Server.UrlDecode(param);
            MoMoSecurity crypto = new MoMoSecurity();
            string serectKey = ConfigurationManager.AppSettings["serectKey"].ToString();
            //Thành công = 1
            //Thất bại = 0
            //Chờ thanh toán = -1
            string signature = crypto.signSHA256(param, serectKey);
            if (signature != Request["signature"].ToString())
            {
                //Fail
            }
            string status_code = Request["status_code"].ToString();
            if (status_code != "0")
            {
                //Fail
            }
            else
            {
                //Success
            }
            return Json("", JsonRequestBehavior.AllowGet);
        }
    }
}