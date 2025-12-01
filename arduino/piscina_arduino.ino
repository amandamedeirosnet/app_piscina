/*
 * ===============================================
 * SISTEMA DE CONTROLE DE PISCINA - ARDUINO
 * ===============================================
 * 
 * Este código permite que o Arduino receba comandos de um app Flutter
 * para controlar equipamentos da piscina (bombas, válvulas, sensores)
 * 
 * Comunicação: WiFi (HTTP) + Bluetooth (Serial)
 * 
 * Autor: Sistema de Piscina Inteligente
 * Data: 2024
 */

#include <WiFi.h>
#include <WebServer.h>
#include <ArduinoJson.h>
#include <BluetoothSerial.h>

// ===============================================
// CONFIGURAÇÕES DE REDE
// ===============================================
const char* ssid = "WIFI_EDUC_CFP502";
const char* password = "Ac5ce0ss2@Educ";
const int serverPort = 80;

// ===============================================
// DEFINIÇÃO DOS PINOS
// ===============================================
// Relés para controle de equipamentos
#define RELE_PH_MAIS        26    // Bomba para aumentar pH
#define RELE_PH_MENOS       25    // Bomba para diminuir pH
#define RELE_CLORO          27    // Bomba de cloro

// Sensores analógicos
#define SENSOR_PH           A0    // Sensor de pH
#define SENSOR_CLORO        A1    // Sensor de cloro
#define SENSOR_TEMPERATURA  A2    // Sensor de temperatura

// LEDs de status
#define LED_WIFI            2     // LED indicador WiFi
#define LED_BLUETOOTH       4     // LED indicador Bluetooth
#define LED_ERRO            5     // LED de erro

// ===============================================
// VARIÁVEIS GLOBAIS
// ===============================================
WebServer server(serverPort);
BluetoothSerial SerialBT;

// Estrutura para armazenar dados da piscina
struct DadosPiscina {
  float ph = 7.0;
  float cloro = 1.0;
  float temperatura = 25.0;
  bool modoAutomatico = true;
  String ultimaAtualizacao = "";
};

DadosPiscina piscina;

// ===============================================
// CONFIGURAÇÃO INICIAL
// ===============================================
void setup() {
  Serial.begin(115200);
  SerialBT.begin("Piscina_Arduino"); // Nome do dispositivo Bluetooth
  
  // Configurar pinos
  configurarPinos();
  
  // Conectar ao WiFi
  conectarWiFi();
  
  // Configurar servidor web
  configurarServidorWeb();
  
  // Configurar Bluetooth
  configurarBluetooth();
  
  Serial.println("=== SISTEMA DE PISCINA INICIADO ===");
  Serial.println("WiFi: " + String(WiFi.localIP().toString()));
  Serial.println("Bluetooth: Piscina_Arduino");
  Serial.println("=====================================");
}

// ===============================================
// LOOP PRINCIPAL
// ===============================================
void loop() {
  // Processar requisições HTTP
  server.handleClient();
  
  // Processar comandos Bluetooth
  processarBluetooth();
  
  // Leitura dos sensores (a cada 5 segundos)
  static unsigned long ultimaLeitura = 0;
  if (millis() - ultimaLeitura > 5000) {
    lerSensores();
    ultimaLeitura = millis();
  }
  
  // Controle automático (se habilitado)
  if (piscina.modoAutomatico) {
    controleAutomatico();
  }
  
  delay(100);
}

// ===============================================
// CONFIGURAÇÃO DOS PINOS
// ===============================================
void configurarPinos() {
  // Configurar relés como saída
  pinMode(RELE_PH_MAIS, OUTPUT);
  pinMode(RELE_PH_MENOS, OUTPUT);
  pinMode(RELE_CLORO, OUTPUT);
  
  // Configurar LEDs
  pinMode(LED_WIFI, OUTPUT);
  pinMode(LED_BLUETOOTH, OUTPUT);
  pinMode(LED_ERRO, OUTPUT);
  
  // Desligar todos os relés inicialmente
  digitalWrite(RELE_PH_MAIS, LOW);
  digitalWrite(RELE_PH_MENOS, LOW);
  digitalWrite(RELE_CLORO, LOW);
  
  // LEDs iniciais
  digitalWrite(LED_WIFI, LOW);
  digitalWrite(LED_BLUETOOTH, LOW);
  digitalWrite(LED_ERRO, LOW);
}

// ===============================================
// CONEXÃO WIFI
// ===============================================
void conectarWiFi() {
  WiFi.begin(ssid, password);
  Serial.print("Conectando ao WiFi");
  
  int tentativas = 0;
  while (WiFi.status() != WL_CONNECTED && tentativas < 20) {
    delay(1000);
    Serial.print(".");
    tentativas++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n✅ WiFi conectado!");
    Serial.println("IP: " + WiFi.localIP().toString());
    digitalWrite(LED_WIFI, HIGH);
  } else {
    Serial.println("\n❌ Falha na conexão WiFi");
    digitalWrite(LED_ERRO, HIGH);
  }
}

// ===============================================
// CONFIGURAÇÃO DO SERVIDOR WEB
// ===============================================
void configurarServidorWeb() {
  // Rota para receber dados do Flutter
  server.on("/api/dados", HTTP_POST, []() {
    receberDadosFlutter();
  });
  
  // Rota para enviar status atual
  server.on("/api/status", HTTP_GET, []() {
    enviarStatusAtual();
  });
  
  // Rota para controle manual
  server.on("/api/controle", HTTP_POST, []() {
    controleManual();
  });
  
  // Rota para configurações
  server.on("/api/config", HTTP_POST, []() {
    configurarSistema();
  });
  
  // Rota de teste
  server.on("/api/teste", HTTP_GET, []() {
    server.send(200, "application/json", "{\"status\":\"ok\",\"mensagem\":\"Sistema funcionando!\"}");
  });
  
  server.begin();
  Serial.println("🌐 Servidor web iniciado na porta " + String(serverPort));
}

// ===============================================
// CONFIGURAÇÃO BLUETOOTH
// ===============================================
void configurarBluetooth() {
  if (SerialBT.begin("Piscina_Arduino")) {
    Serial.println("📱 Bluetooth iniciado: Piscina_Arduino");
    digitalWrite(LED_BLUETOOTH, HIGH);
  } else {
    Serial.println("❌ Erro ao iniciar Bluetooth");
  }
}

// ===============================================
// RECEBER DADOS DO FLUTTER (WiFi)
// ===============================================
void receberDadosFlutter() {
  if (!server.hasArg("plain")) {
    server.send(400, "application/json", "{\"erro\":\"Dados não encontrados\"}");
    return;
  }
  
  String body = server.arg("plain");
  Serial.println("📱 Dados recebidos do Flutter: " + body);
  
  // Parse do JSON
  DynamicJsonDocument doc(1024);
  DeserializationError error = deserializeJson(doc, body);
  
  if (error) {
    Serial.println("❌ Erro no parse JSON: " + String(error.c_str()));
    server.send(400, "application/json", "{\"erro\":\"JSON inválido\"}");
    return;
  }
  
  // Processar dados recebidos
  if (doc.containsKey("ph")) {
    piscina.ph = doc["ph"];
    Serial.println("pH atualizado: " + String(piscina.ph));
  }
  
  if (doc.containsKey("cloro")) {
    piscina.cloro = doc["cloro"];
    Serial.println("Cloro atualizado: " + String(piscina.cloro));
  }
  
  if (doc.containsKey("temperatura")) {
    piscina.temperatura = doc["temperatura"];
    Serial.println("Temperatura atualizada: " + String(piscina.temperatura));
  }

  
  piscina.ultimaAtualizacao = String(millis());
  
  // Resposta de sucesso
  server.send(200, "application/json", 
    "{\"status\":\"ok\",\"mensagem\":\"Dados recebidos com sucesso\"}");
}

// ===============================================
// ENVIAR STATUS ATUAL
// ===============================================
void enviarStatusAtual() {
  DynamicJsonDocument doc(1024);
  
  doc["ph"] = piscina.ph;
  doc["cloro"] = piscina.cloro;
  doc["temperatura"] = piscina.temperatura;
  doc["modoAutomatico"] = piscina.modoAutomatico;
  doc["wifiConectado"] = (WiFi.status() == WL_CONNECTED);
  doc["ultimaAtualizacao"] = piscina.ultimaAtualizacao;
  
  String response;
  serializeJson(doc, response);
  server.send(200, "application/json", response);
}

// ===============================================
// CONTROLE MANUAL
// ===============================================
void controleManual() {
  if (!server.hasArg("plain")) {
    server.send(400, "application/json", "{\"erro\":\"Dados não encontrados\"}");
    return;
  }
  
  String body = server.arg("plain");
  DynamicJsonDocument doc(512);
  DeserializationError error = deserializeJson(doc, body);
  
  if (error) {
    server.send(400, "application/json", "{\"erro\":\"JSON inválido\"}");
    return;
  }
  
  // Controlar equipamentos (apenas pH e cloro)
  if (doc.containsKey("ph_mais")) {
    bool ligar = doc["ph_mais"];
    digitalWrite(RELE_PH_MAIS, ligar ? HIGH : LOW);
    Serial.println("pH+ " + String(ligar ? "ligado" : "desligado"));
  }
  
  if (doc.containsKey("ph_menos")) {
    bool ligar = doc["ph_menos"];
    digitalWrite(RELE_PH_MENOS, ligar ? HIGH : LOW);
    Serial.println("pH- " + String(ligar ? "ligado" : "desligado"));
  }
  
  if (doc.containsKey("cloro")) {
    bool ligar = doc["cloro"];
    digitalWrite(RELE_CLORO, ligar ? HIGH : LOW);
    Serial.println("Cloro " + String(ligar ? "ligado" : "desligado"));
  }
  
  server.send(200, "application/json", "{\"status\":\"ok\"}");
}

// ===============================================
// CONFIGURAR SISTEMA
// ===============================================
void configurarSistema() {
  if (!server.hasArg("plain")) {
    server.send(400, "application/json", "{\"erro\":\"Dados não encontrados\"}");
    return;
  }
  
  String body = server.arg("plain");
  DynamicJsonDocument doc(512);
  DeserializationError error = deserializeJson(doc, body);
  
  if (error) {
    server.send(400, "application/json", "{\"erro\":\"JSON inválido\"}");
    return;
  }
  
  // Aqui você pode adicionar configurações específicas
  // como limites de pH, cloro, horários, etc.
  
  server.send(200, "application/json", "{\"status\":\"ok\"}");
}

// ===============================================
// PROCESSAR BLUETOOTH
// ===============================================
void processarBluetooth() {
  if (SerialBT.available()) {
    String comando = SerialBT.readString();
    comando.trim();
    
    Serial.println("📱 Comando Bluetooth: " + comando);
    
    // Processar comandos simples via Bluetooth
    if (comando == "STATUS") {
      enviarStatusBluetooth();
    } else if (comando == "PH_MAIS_ON") {
      digitalWrite(RELE_PH_MAIS, HIGH);
      SerialBT.println("pH+ ligado");
    } else if (comando == "PH_MAIS_OFF") {
      digitalWrite(RELE_PH_MAIS, LOW);
      SerialBT.println("pH+ desligado");
    } else if (comando == "PH_MENOS_ON") {
      digitalWrite(RELE_PH_MENOS, HIGH);
      SerialBT.println("pH- ligado");
    } else if (comando == "PH_MENOS_OFF") {
      digitalWrite(RELE_PH_MENOS, LOW);
      SerialBT.println("pH- desligado");
    } else if (comando == "CLORO_ON") {
      digitalWrite(RELE_CLORO, HIGH);
      SerialBT.println("Cloro ligado");
    } else if (comando == "CLORO_OFF") {
      digitalWrite(RELE_CLORO, LOW);
      SerialBT.println("Cloro desligado");
    } else if (comando.startsWith("PH:")) {
      float novoPh = comando.substring(3).toFloat();
      piscina.ph = novoPh;
      SerialBT.println("pH definido para: " + String(novoPh));
    } else {
      SerialBT.println("Comando não reconhecido: " + comando);
    }
  }
}

// ===============================================
// ENVIAR STATUS VIA BLUETOOTH
// ===============================================
void enviarStatusBluetooth() {
  String status = "STATUS:";
  status += "pH=" + String(piscina.ph) + ",";
  status += "Cloro=" + String(piscina.cloro) + ",";
  status += "Temp=" + String(piscina.temperatura) + ",";
  status += "pH+=" + String(digitalRead(RELE_PH_MAIS) ? "ON" : "OFF") + ",";
  status += "pH-=" + String(digitalRead(RELE_PH_MENOS) ? "ON" : "OFF") + ",";
  status += "Cloro=" + String(digitalRead(RELE_CLORO) ? "ON" : "OFF");
  
  SerialBT.println(status);
}

// ===============================================
// LEITURA DOS SENSORES
// ===============================================
void lerSensores() {
  // Leitura do sensor de pH (simulado)
  int valorPh = analogRead(SENSOR_PH);
  piscina.ph = map(valorPh, 0, 4095, 0, 140) / 10.0; // 0-14 pH
  
  // Leitura do sensor de cloro (simulado)
  int valorCloro = analogRead(SENSOR_CLORO);
  piscina.cloro = map(valorCloro, 0, 4095, 0, 50) / 10.0; // 0-5 ppm
  
  // Leitura do sensor de temperatura (simulado)
  int valorTemp = analogRead(SENSOR_TEMPERATURA);
  piscina.temperatura = map(valorTemp, 0, 4095, 0, 500) / 10.0; // 0-50°C
  
  Serial.println("📊 Sensores - pH: " + String(piscina.ph) + 
                ", Cloro: " + String(piscina.cloro) + 
                ", Temp: " + String(piscina.temperatura) + "°C");
}

// ===============================================
// CONTROLE AUTOMÁTICO
// ===============================================
void controleAutomatico() {
  // Controle de pH
  if (piscina.ph < 7.0) {
    digitalWrite(RELE_PH_MAIS, HIGH);  // Adicionar pH+
    digitalWrite(RELE_PH_MENOS, LOW);
  } else if (piscina.ph > 7.8) {
    digitalWrite(RELE_PH_MAIS, LOW);
    digitalWrite(RELE_PH_MENOS, HIGH); // Adicionar pH-
  } else {
    digitalWrite(RELE_PH_MAIS, LOW);
    digitalWrite(RELE_PH_MENOS, LOW);
  }
  
  // Controle de cloro
  if (piscina.cloro < 1.0) {
    digitalWrite(RELE_CLORO, HIGH);    // Adicionar cloro
  } else {
    digitalWrite(RELE_CLORO, LOW);
  }
  
  // Controle de temperatura (apenas monitoramento)
  // A temperatura é apenas lida, não controlada
  Serial.println("🌡️ Temperatura: " + String(piscina.temperatura) + "°C");
}

// ===============================================
// FUNÇÕES AUXILIARES
// ===============================================

// Função para extrair valores de JSON simples (compatibilidade)
float getValue(String json, String key) {
  int i = json.indexOf(key);
  if (i == -1) return -1;
  int start = json.indexOf(":", i) + 1;
  int end = json.indexOf(",", start);
  if (end == -1) end = json.indexOf("}", start);
  return json.substring(start, end).toFloat();
}

// Função para verificar conexão WiFi
bool verificarConexaoWiFi() {
  return WiFi.status() == WL_CONNECTED;
}

// Função para reiniciar sistema
void reiniciarSistema() {
  Serial.println("🔄 Reiniciando sistema...");
  delay(1000);
  ESP.restart();
}
