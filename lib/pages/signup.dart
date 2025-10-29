import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart'; 
import 'node_model.dart'; 

//Registreringssida
class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  //Global nyckel för formulärvalidering
  final _formKey = GlobalKey<FormState>();

  //TextEditetingControllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true; //Varibel för att dölja lösenord
  bool _loading = false; //Variabel för att visa laddningsindikator

  //Huvudfunktion för att registrera användaren
  void _trySignup() async {
    //Validerar alla fält i formuläret
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _loading = true);

    try {
      //Skapa användare i Firebase Authentication
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //Spara användardata i Firestore
      await saveUserData(name);

      if (mounted) {
        // Navigera till HuvudNavigator
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HuvudNavigator()),
        );
      }
    } on FirebaseAuthException catch (e) {
      //Felhantering för specifika felkoder
      String message = 'Ett fel uppstod vid registreringen.';

      switch (e.code) {
        case 'email-already-in-use':
          message = 'E-postadressen används redan. Försök logga in istället.';
          break;
        case 'invalid-email':
          message = 'E-postadressen är ogiltig.';
          break;
        case 'weak-password':
          message = 'Lösenordet är för svagt.';
          break;
        case 'network-request-failed':
          message = 'Nätverksfel. Kontrollera din internetanslutning.';
          break;
        default:
          message = 'Ett okänt fel inträffade (${e.code}).';
      }

      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
        //Hantering av allmänna fel
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Okänt fel: $e')),
            );
        }
    } finally {
      //Stänger av laddningsindikatorn oavsett reslutat
      if (mounted) setState(() => _loading = false);
    }
}

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).appBarTheme.backgroundColor ?? const Color(0xFF8CA1DE);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skapa konto'),
        backgroundColor: primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                //Namnfält
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Namn',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ange namn';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                //E-post fält
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-post',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ange e-post';
                    if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+").hasMatch(v)) {
                      return 'Ogiltig e-post';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                //Lösenordsfält
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Lösenord',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    //Knapp för att visa/dölja löseord
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ange lösenord';
                    if (v.length < 6) return 'Minst 6 tecken';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                //Bekräfta löseordsfält
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscure,
                  decoration: const InputDecoration(
                    labelText: 'Bekräfta lösenord',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Bekräfta lösenord';
                    if (v != _passwordController.text) {
                      return 'Lösenorden matchar inte';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                //Registreringsknapp eller laddningsindikator
                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _trySignup,
                        child: const Text('Skapa konto',
                            style: TextStyle(fontSize: 16)),
                      ),                
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Frigöra minne från TextControllers när widgeten tas bort
  @override
  void dispose() {
    _nameController.dispose(); 
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}