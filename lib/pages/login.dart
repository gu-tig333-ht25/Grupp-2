import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Inloggningssida
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Global nyckel för formulärvalidering
  final _formKey = GlobalKey<FormState>();
  
  // Texteditingcontrollers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true; //Variabel som döljer lösenord
  bool _loading = false; //Variabel som visar laddningsindikator

  //Huvudfunktion för att logga in
  void _tryLogin() async {
    //Validerar alla fält
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    //Sätter laddningsstatus till sann
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      //Försöker logga in med Firebase autentication
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // AuthGate i main.dart hanterar navigering till HuvudNavigator vid lyckad inloggning

    } on FirebaseAuthException catch (e) {
      //Felhantering för specifika fel
      String message = 'Ett fel uppstod';
      if (e.code == 'user-not-found') message = 'Användare hittades inte';
      if (e.code == 'wrong-password') message = 'Fel lösenord';
      if (e.code == 'invalid-email') message = 'Ogiltig e-postadress';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      //Stänger laddningsindikatorn oavsett resultat
      if (mounted) setState(() => _loading = false);
    }
  }

// Frigör minne från TextControllers när widgeten tas bort
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    final primaryColor = Theme.of(context).appBarTheme.backgroundColor ?? const Color(0xFF8CA1DE);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Logga in'), backgroundColor: primaryColor),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                //E-post fält
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'E-post', prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ange e-post';
                    if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+").hasMatch(v)) return 'Ogiltig e-post';
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
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Ange lösenord' : null,
                ),
                const SizedBox(height: 20),
               
               //Inloggningsknapp eller laddningsindikator
               _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _tryLogin,
                        child: const Text('Logga in', style: TextStyle(fontSize: 16)),
                      ),
                const SizedBox(height: 12),
                
                //Knapp för att navigera till registreringssidan
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text('Skapa konto'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}