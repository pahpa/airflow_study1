# 🚀 Autoformation Airflow par l'exemple (Docker v2.0)

---

> 💡 **Avertissement / Disclaimer** : 
> Ce projet a été développé avec l'assistance d'une Intelligence Artificielle (Gemini), ce qui a permis un gain de temps considérable sur la génération du boilerplate, la documentation et le scriptage du Makefile. 
> 
> Cependant, la structure, les choix d'architecture (Dockerisation, gestion des volumes, permissions Ubuntu) et la validation finale ont été entièrement pilotés par mon expérience technique. L'IA a servi d'outil d'exécution et de partenaire de réflexion, mais le contrôle de la cohérence et de la sécurité du résultat reste le fruit d'une supervision humaine qualifiée.

---

## 📚 Documentation

Vous pouvez consulter la documentation complète dans la langue de votre choix :

- 🇫🇷 [Documentation en Français](./README-fr.txt)
- 🇬🇧 [Documentation in English](./README-en.txt)

---

### 🛠️ Aperçu Rapide (Quick Start)
1. `make airflow-init`
2. `sudo chown -R $USER:$USER . && sudo chmod -R 775 ./dags ./logs ./plugins ./config`
3. `make airflow-run`
