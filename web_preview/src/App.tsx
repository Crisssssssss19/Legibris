import React, { useState, useEffect } from 'react';
import { 
  BookOpen, 
  Search, 
  Bookmark, 
  BarChart3, 
  Flame, 
  Award, 
  TrendingUp, 
  Plus, 
  Smartphone, 
  Mail, 
  Lock, 
  Eye, 
  EyeOff, 
  Check, 
  ChevronLeft, 
  ChevronRight, 
  Star, 
  Bell, 
  SlidersHorizontal, 
  Calendar,
  Grid,
  Sparkles,
  Info,
  Clock,
  LogOut,
  HelpCircle,
  FolderHeart,
  User
} from 'lucide-react';
import { supabase } from './supabaseClient';

// Define standard types for our preview app
type Screen = 'onboarding' | 'login' | 'register' | 'home' | 'shelf' | 'stats' | 'calendar' | 'goals' | 'premium' | 'profile';

interface Book {
  id: string;
  title: string;
  author: string;
  progress: number;
  status: 'leyendo' | 'leido' | 'pendiente' | 'favorito';
}

export default function App() {
  // Navigation & Screen Controls
  const [currentScreen, setCurrentScreen] = useState<Screen>('onboarding');
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [simulatedPlatform, setSimulatedPlatform] = useState<'web' | 'android' | 'ios'>('web');
  
  // Interactive mock user variables / Supabase auth session
  const [session, setSession] = useState<any>(null);
  const [username, setUsername] = useState('cris_lector');
  const [fullName, setFullName] = useState('Cris Lector');
  const [bio, setBio] = useState('Apasionado de la ciencia ficción, la historia y el desarrollo personal.');
  const [email, setEmail] = useState('cris@ejemplo.com');
  const [password, setPassword] = useState('seguridad123');
  const [acceptTerms, setAcceptTerms] = useState(false);

  // Custom alert modal state
  const [alertModal, setAlertModal] = useState<{ show: boolean; title: string; message: string }>({
    show: false,
    title: '',
    message: ''
  });

  // Add book modal state
  const [addBookModal, setAddBookModal] = useState(false);
  const [newBookTitle, setNewBookTitle] = useState('');
  const [newBookAuthor, setNewBookAuthor] = useState('');

  // App Reading States
  const [habitosProgress, setHabitosProgress] = useState(68);
  const [streakDays, setStreakDays] = useState([true, true, true, true, true, false, false]); // Mon - Sun
  const [selectedPlan, setSelectedPlan] = useState<'mensual' | 'anual'>('anual');

  // Book Library state
  const [books, setBooks] = useState<Book[]>([
    { id: '1', title: 'Hábitos Atómicos', author: 'James Clear', progress: 68, status: 'leyendo' },
    { id: '2', title: 'Sapiens', author: 'Yuval Noah Harari', progress: 100, status: 'leido' },
    { id: '3', title: 'El monje que vendió su Ferrari', author: 'Robin Sharma', progress: 100, status: 'leido' },
    { id: '4', title: '1984', author: 'George Orwell', progress: 100, status: 'leido' },
    { id: '5', title: 'Los 7 hábitos de la gente altamente efectiva', author: 'Stephen Covey', progress: 100, status: 'leido' },
    { id: '6', title: 'El poder del AHORA', author: 'Eckhart Tolle', progress: 100, status: 'leido' },
    { id: '7', title: 'Padre rico padre pobre', author: 'Robert Kiyosaki', progress: 100, status: 'leido' },
    { id: '8', title: 'Piense y hágase rico', author: 'Napoleon Hill', progress: 100, status: 'leido' },
  ]);

  // Current shelf filter
  const [shelfFilter, setShelfFilter] = useState<'leido' | 'leyendo' | 'pendiente' | 'favorito'>('leido');

  // Calendar dates log helper
  const readDates = [2, 6, 8, 10, 13, 19, 22, 27, 30];
  const [loggedDays, setLoggedDays] = useState<number[]>(readDates);

  // Helper function to trigger the custom alert modal
  const triggerAlert = (title: string, message: string) => {
    setAlertModal({ show: true, title, message });
  };

  // ---------------------------------------------------------------------------
  // SUPABASE INTEGRATION HANDLERS
  // ---------------------------------------------------------------------------

  // Check auth session on startup
  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      if (session) {
        setEmail(session.user.email || '');
        fetchProfile(session.user.id);
        fetchUserBooks(session.user.id);
        setCurrentScreen('home');
      }
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
      if (session) {
        setEmail(session.user.email || '');
        fetchProfile(session.user.id);
        fetchUserBooks(session.user.id);
        setCurrentScreen('home');
      } else {
        setCurrentScreen('login');
      }
    });

    return () => subscription.unsubscribe();
  }, []);

  // Fetch profiles table
  const fetchProfile = async (uid: string) => {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', uid)
        .maybeSingle();

      if (error) throw error;
      if (data) {
        setUsername(data.username || 'cris_lector');
        setFullName(data.full_name || 'Cris Lector');
        setBio(data.bio || 'Apasionado de la lectura');
      }
    } catch (e) {
      console.log('Falta tabla profiles en Supabase (usando datos mock locales)');
    }
  };

  // Fetch books from user_books linked to books catalog
  const fetchUserBooks = async (uid: string) => {
    try {
      const { data, error } = await supabase
        .from('user_books')
        .select('*, book:books(*)')
        .eq('user_id', uid);

      if (error) throw error;
      if (data && data.length > 0) {
        const parsedBooks: Book[] = data.map((item: any) => ({
          id: item.book.id,
          title: item.book.title,
          author: item.book.publisher || 'Autor Desconocido',
          progress: item.status === 'leido' ? 100 : 40,
          status: item.status
        }));
        setBooks(parsedBooks);
      }
    } catch (e) {
      console.log('Falta tabla user_books en Supabase (usando catálogo mock local)');
    }
  };

  // Sign In using Supabase auth
  const handleSupabaseLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const { error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (error) {
        triggerAlert('Error', `Error al iniciar sesión: ${error.message}`);
      } else {
        triggerAlert('Éxito', 'Sesión iniciada con éxito en tu base de datos Supabase!');
        setCurrentScreen('home');
      }
    } catch (err: any) {
      triggerAlert('Error', `Error de conexión: ${err.message}`);
    }
  };

  // Sign Up using Supabase auth
  const handleSupabaseSignUp = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!acceptTerms) {
      triggerAlert('Términos', 'Debes aceptar los términos y condiciones.');
      return;
    }

    try {
      const { error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            username: username,
            full_name: fullName,
          }
        }
      });

      if (error) {
        triggerAlert('Error', `Error de registro: ${error.message}`);
      } else {
        triggerAlert('Éxito', 'Cuenta creada exitosamente en Supabase! Revisa tu correo para verificar el enlace.');
        setCurrentScreen('login');
      }
    } catch (err: any) {
      triggerAlert('Error', `Error de conexión: ${err.message}`);
    }
  };

  // Log Out helper
  const handleSupabaseLogout = async () => {
    await supabase.signOut();
    setSession(null);
    setCurrentScreen('onboarding');
  };

  // Open the add book modal
  const handleAddBook = () => {
    setAddBookModal(true);
  };

  // Submit new book creation
  const submitNewBook = async () => {
    if (!newBookTitle || !newBookAuthor) {
      triggerAlert('Falta información', 'Por favor completa el título y el autor del libro.');
      return;
    }

    const title = newBookTitle;
    const author = newBookAuthor;

    // Local update
    const newBook: Book = {
      id: Date.now().toString(),
      title,
      author,
      progress: 0,
      status: 'pendiente'
    };
    setBooks([...books, newBook]);
    setShelfFilter('pendiente');
    setAddBookModal(false);
    setNewBookTitle('');
    setNewBookAuthor('');

    // Attempt Supabase insert
    if (session) {
      try {
        const { data: bookData, error: bookError } = await supabase
          .from('books')
          .upsert({ title, publisher: author })
          .select()
          .single();

        if (bookError) throw bookError;

        if (bookData) {
          const { error: linkError } = await supabase
            .from('user_books')
            .insert({
              user_id: session.user.id,
              book_id: bookData.id,
              status: 'pendiente'
            });

          if (linkError) throw linkError;
          console.log('Libro sincronizado con Supabase.');
        }
      } catch (e) {
        console.log('Error insertando en Supabase (ejecutando en modo local cache)');
      }
    }
  };

  // Increase "Hábitos Atómicos" progress
  const increaseProgress = async () => {
    setHabitosProgress(prev => {
      const next = prev + 8;
      if (next >= 100) {
        setBooks(books.map(b => b.id === '1' ? { ...b, progress: 100, status: 'leido' } : b));
        return 100;
      }
      return next;
    });

    // Sync session duration if online
    if (session) {
      try {
        await supabase.from('reading_sessions').insert({
          user_id: session.user.id,
          book_id: '1',
          duration_minutes: 15,
          pages_read: 8,
        });
      } catch (e) {
        console.log('Sesión de lectura en caché local.');
      }
    }
  };

  // Toggle calendar days completed
  const toggleCalendarDay = async (day: number) => {
    if (loggedDays.includes(day)) {
      setLoggedDays(loggedDays.filter(d => d !== day));
    } else {
      setLoggedDays([...loggedDays, day]);
    }
  };

  // Toggle streak weekdays
  const toggleStreakDay = (idx: number) => {
    const newStreaks = [...streakDays];
    newStreaks[idx] = !newStreaks[idx];
    setStreakDays(newStreaks);
  };

  const currentStreakCount = streakDays.filter(d => d).length;

  return (
    <div className="web-app-layout">
      {/* Top sticky frosted-glass Navigation Bar */}
      <header className="web-navbar">
        <div className="navbar-container">
          <div className="navbar-brand" onClick={() => setCurrentScreen('home')}>
            <span className="navbar-logo">
              <BookOpen size={24} />
            </span>
            <span className="navbar-title">Legibris</span>
          </div>

          <nav className="navbar-links">
            <button 
              className={`nav-link ${currentScreen === 'home' ? 'active' : ''}`} 
              onClick={() => setCurrentScreen('home')}
            >
              Inicio
            </button>
            <button 
              className={`nav-link ${currentScreen === 'shelf' ? 'active' : ''}`} 
              onClick={() => setCurrentScreen('shelf')}
            >
              Estantería
            </button>
            <button 
              className={`nav-link ${['stats', 'calendar'].includes(currentScreen) ? 'active' : ''}`} 
              onClick={() => setCurrentScreen('stats')}
            >
              Estadísticas
            </button>
            <button 
              className={`nav-link ${currentScreen === 'goals' ? 'active' : ''}`} 
              onClick={() => setCurrentScreen('goals')}
            >
              Metas
            </button>
            <button 
              className={`nav-link ${currentScreen === 'premium' ? 'active' : ''}`} 
              onClick={() => setCurrentScreen('premium')}
            >
              Premium
            </button>
          </nav>

          <div className="navbar-actions">
            <div className="search-bar">
              <Search size={16} className="search-icon" />
              <input type="text" placeholder="Buscar libros, autores..." className="search-input" />
            </div>

            {session ? (
              <div className="profile-dropdown-trigger" onClick={() => setCurrentScreen('profile')}>
                <span className="avatar-mini">👤</span>
                <span className="username-label">@{username}</span>
              </div>
            ) : (
              <div style={{ display: 'flex', gap: '8px' }}>
                <button className="btn-navbar-sec" onClick={() => setCurrentScreen('login')}>Iniciar Sesión</button>
                <button className="btn-navbar-pri" onClick={() => setCurrentScreen('register')}>Registrarse</button>
              </div>
            )}
          </div>
        </div>
      </header>

      {/* Main Responsive Content Viewport */}
      <main className="web-main-content">

            {/* 1. ONBOARDING SCREEN */}
            {currentScreen === 'onboarding' && (
              <div className="onboarding-screen">
                <div className="onboarding-bg">
                  <div className="onboarding-logo">
                    <BookOpen size={48} />
                  </div>
                  <h2 className="onboarding-welcome-text">Legibris</h2>
                  <p className="onboarding-subtitle">Tu biblioteca. Tus metas. Tu historia.</p>
                  
                  <div className="onboarding-features">
                    <div className="onboarding-feature-row">
                      <Search className="onboarding-feature-icon" size={24} />
                      <div>
                        <h4 className="onboarding-feature-title">Catálogo inteligente</h4>
                        <p className="onboarding-feature-desc">Descubre libros y añade a tu lista de lectura rápidamente.</p>
                      </div>
                    </div>
                    
                    <div className="onboarding-feature-row">
                      <Bookmark className="onboarding-feature-icon" size={24} />
                      <div>
                        <h4 className="onboarding-feature-title">Estantería personal</h4>
                        <p className="onboarding-feature-desc">Organiza tus libros en hermosas colecciones.</p>
                      </div>
                    </div>

                    <div className="onboarding-feature-row">
                      <BarChart3 className="onboarding-feature-icon" size={24} />
                      <div>
                        <h4 className="onboarding-feature-title">Estadísticas detalladas</h4>
                        <p className="onboarding-feature-desc">Visualiza tus hábitos, páginas leídas y tendencias.</p>
                      </div>
                    </div>

                    <div className="onboarding-feature-row">
                      <Flame className="onboarding-feature-icon" size={24} />
                      <div>
                        <h4 className="onboarding-feature-title">Metas y rachas</h4>
                        <p className="onboarding-feature-desc">Fija tus metas mensuales y mantén el hábito diario.</p>
                      </div>
                    </div>
                  </div>
                </div>

                <button className="btn-primary" onClick={() => setCurrentScreen('login')}>
                  Comenzar
                </button>
                <button className="btn-text" onClick={() => setCurrentScreen('login')}>
                  ¿Ya tienes cuenta? Inicia sesión
                </button>
              </div>
            )}

            {/* 2. LOGIN SCREEN */}
            {currentScreen === 'login' && (
              <div className="screen-content auth-screen">
                <div className="auth-header-container">
                  <div className="auth-logo">
                    <BookOpen size={28} />
                  </div>
                  <h2 className="auth-title">Bienvenido</h2>
                  <p className="auth-subtitle">Inicia sesión para continuar en Legibris</p>
                </div>

                <form onSubmit={handleSupabaseLogin}>
                  <div className="form-group">
                    <Mail className="form-icon" size={18} />
                    <input 
                      type="email" 
                      placeholder="Correo electrónico" 
                      className="form-input" 
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      required
                    />
                  </div>

                  <div className="form-group" style={{ marginBottom: '24px' }}>
                    <Lock className="form-icon" size={18} />
                    <input 
                      type={showPassword ? 'text' : 'password'} 
                      placeholder="Contraseña" 
                      className="form-input"
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      required
                    />
                    <button type="button" className="form-eye" onClick={() => setShowPassword(!showPassword)}>
                      {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                    </button>
                  </div>

                  <button type="submit" className="btn-primary" style={{ width: '100%' }}>
                    Iniciar sesión
                  </button>
                </form>

                <div className="social-auth-divider">
                  <div className="divider-line"></div>
                  <span className="divider-text">o continúa con</span>
                  <div className="divider-line"></div>
                </div>

                <div className="social-btns-container">
                  <button className="btn-social" onClick={() => setCurrentScreen('home')}>
                    <span style={{ color: '#EA4335', fontWeight: 'bold' }}>G</span> Google
                  </button>
                  <button className="btn-social" onClick={() => setCurrentScreen('home')}>
                    <span></span> Apple
                  </button>
                </div>

                <div style={{ marginTop: '32px', textAlign: 'center', fontSize: '0.85rem' }}>
                  <span>¿No tienes cuenta? </span>
                  <button className="btn-text" style={{ padding: 0 }} onClick={() => setCurrentScreen('register')}>
                    Regístrate
                  </button>
                </div>
              </div>
            )}

            {/* 3. REGISTER SCREEN */}
            {currentScreen === 'register' && (
              <div className="screen-content auth-screen">
                <div className="auth-header-container">
                  <div className="auth-logo">
                    <BookOpen size={28} />
                  </div>
                  <h2 className="auth-title">Crea tu cuenta</h2>
                  <p className="auth-subtitle">Únete a miles de lectores hoy mismo</p>
                </div>

                <form onSubmit={handleSupabaseSignUp}>
                  <div className="form-group">
                    <Smartphone className="form-icon" size={18} />
                    <input 
                      type="text" 
                      placeholder="Nombre de usuario" 
                      className="form-input" 
                      value={username}
                      onChange={(e) => setUsername(e.target.value)}
                      required
                    />
                  </div>

                  <div className="form-group">
                    <Mail className="form-icon" size={18} />
                    <input 
                      type="email" 
                      placeholder="Correo electrónico" 
                      className="form-input" 
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      required
                    />
                  </div>

                  <div className="form-group">
                    <Lock className="form-icon" size={18} />
                    <input 
                      type={showPassword ? 'text' : 'password'} 
                      placeholder="Contraseña" 
                      className="form-input"
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      required
                    />
                    <button type="button" className="form-eye" onClick={() => setShowPassword(!showPassword)}>
                      {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                    </button>
                  </div>

                  <div className="terms-container">
                    <input 
                      type="checkbox" 
                      className="terms-checkbox" 
                      checked={acceptTerms}
                      onChange={(e) => setAcceptTerms(e.target.checked)}
                    />
                    <span className="terms-text">
                      Acepto los Términos y Condiciones y la Política de Privacidad de Legibris.
                    </span>
                  </div>

                  <button 
                    type="submit"
                    className="btn-primary" 
                    style={{ width: '100%', opacity: acceptTerms ? 1 : 0.6 }} 
                    disabled={!acceptTerms}
                  >
                    Registrarme
                  </button>
                </form>

                <div style={{ marginTop: '24px', textAlign: 'center', fontSize: '0.85rem' }}>
                  <span>¿Ya tienes cuenta? </span>
                  <button className="btn-text" style={{ padding: 0 }} onClick={() => setCurrentScreen('login')}>
                    Inicia sesión
                  </button>
                </div>
              </div>
            )}

            {/* 4. HOME (INICIO) SCREEN */}
            {currentScreen === 'home' && (
              <div className="screen-content" style={{ padding: '0 16px 80px 16px' }}>
                <div className="screen-header">
                  <h3 className="screen-title">Inicio</h3>
                  <div style={{ display: 'flex', gap: '8px' }}>
                    <button style={{ border: 'none', background: 'none', color: 'var(--color-brown)', cursor: 'pointer' }} onClick={() => setCurrentScreen('premium')}>
                      <Sparkles size={20} />
                    </button>
                    <button style={{ border: 'none', background: 'none', cursor: 'pointer' }}>
                      <Bell size={20} />
                    </button>
                  </div>
                </div>

                <div className="home-desktop-layout">
                  {/* Left Column: Core Tracking */}
                  <div className="home-main-col">
                    <h4 style={{ fontSize: '1rem', color: 'var(--text-light)', marginBottom: '12px', fontWeight: 'bold' }}>Lectura actual</h4>
                    <div className="current-reading-card" style={{ marginBottom: '24px' }}>
                      <div className="book-cover-mock" style={{ width: '100px', height: '150px', fontSize: '0.9rem' }}>
                        <span>Hábitos<br/>Atómicos</span>
                      </div>
                      <div className="current-reading-info">
                        <h5 className="book-title" style={{ fontSize: '1.2rem' }}>Hábitos Atómicos</h5>
                        <span className="book-author" style={{ fontSize: '0.9rem' }}>James Clear</span>
                        
                        <div className="progress-header" style={{ marginTop: 'auto' }}>
                          <span>Progreso de lectura</span>
                          <span>{habitosProgress}%</span>
                        </div>
                        <div className="progress-bar-container" style={{ margin: '8px 0 16px 0' }}>
                          <div className="progress-bar-fill" style={{ width: `${habitosProgress}%` }}></div>
                        </div>
                        
                        <button className="btn-sm" style={{ alignSelf: 'flex-start', padding: '12px 20px' }} onClick={increaseProgress}>
                          <Clock size={16} /> Continuar leyendo
                        </button>
                      </div>
                    </div>

                    <div className="streak-card" style={{ marginBottom: '24px' }}>
                      <div className="streak-header" style={{ fontSize: '1.1rem' }}>
                        <Flame size={22} color="#FF6B00" fill="#FF6B00" />
                        <span>{currentStreakCount} días de racha de lectura</span>
                      </div>
                      <p className="streak-desc">Toca los días de la semana para registrar tus sesiones de lectura y mantener activa tu racha.</p>
                      
                      <div className="streak-grid" style={{ gap: '12px', justifyContent: 'flex-start' }}>
                        {['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'].map((day, idx) => (
                          <div className="streak-day-cell" key={day + idx} style={{ flex: 1 }}>
                            <span className="streak-day-name">{day}</span>
                            <button 
                              className={`streak-day-bubble ${streakDays[idx] ? 'active' : ''}`}
                              onClick={() => toggleStreakDay(idx)}
                              style={{ width: '40px', height: '40px', cursor: 'pointer' }}
                            >
                              {streakDays[idx] ? <Check size={16} color="white" /> : null}
                            </button>
                          </div>
                        ))}
                      </div>
                    </div>

                    <h4 style={{ fontSize: '1.1rem', color: 'var(--text-light)', marginTop: '20px', marginBottom: '16px', fontWeight: 'bold' }}>
                      Continuar leyendo en tus estanterías
                    </h4>
                    <div className="horizontal-scroll-section" style={{ gap: '16px' }}>
                      <div className="scroll-card" style={{ width: '130px', height: '190px', fontSize: '0.85rem' }} onClick={() => setCurrentScreen('shelf')}>
                        <span>El monje que vendió su Ferrari</span>
                      </div>
                      <div className="scroll-card" style={{ width: '130px', height: '190px', fontSize: '0.85rem' }} onClick={() => setCurrentScreen('shelf')}>
                        <span>Piense y hágase rico</span>
                      </div>
                      <div className="scroll-card" style={{ width: '130px', height: '190px', fontSize: '0.85rem' }} onClick={() => setCurrentScreen('shelf')}>
                        <span>El poder del AHORA</span>
                      </div>
                    </div>
                  </div>

                  {/* Right Column: Month Summary & Stats */}
                  <div className="home-side-col">
                    <div className="summary-header-row" style={{ marginTop: 0, marginBottom: '16px' }}>
                      <h4 style={{ fontSize: '1rem', color: 'var(--text-light)', fontWeight: 'bold' }}>Resumen del mes</h4>
                      <button className="summary-select" onClick={() => setCurrentScreen('stats')}>
                        Este mes v
                      </button>
                    </div>

                    <div className="stats-grid-container" style={{ gridTemplateColumns: '1fr', gap: '16px' }}>
                      <div className="stat-grid-card" style={{ padding: '20px' }}>
                        <span className="stat-grid-value" style={{ fontSize: '1.8rem' }}>24</span>
                        <span className="stat-grid-label" style={{ fontSize: '0.9rem' }}>Libros leídos</span>
                        <span className="stat-grid-change" style={{ fontSize: '0.8rem' }}>↗ 2 vs mes pasado</span>
                      </div>
                      <div className="stat-grid-card" style={{ padding: '20px' }}>
                        <span className="stat-grid-value" style={{ fontSize: '1.8rem' }}>5,891</span>
                        <span className="stat-grid-label" style={{ fontSize: '0.9rem' }}>Páginas leídas</span>
                        <span className="stat-grid-change" style={{ fontSize: '0.8rem' }}>↗ 112 vs mes pasado</span>
                      </div>
                      <div className="stat-grid-card" style={{ padding: '20px' }}>
                        <span className="stat-grid-value" style={{ fontSize: '1.8rem' }}>14h 32m</span>
                        <span className="stat-grid-label" style={{ fontSize: '0.9rem' }}>Tiempo de lectura total</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* 5. SHELF (ESTANTERÍA) SCREEN */}
            {currentScreen === 'shelf' && (
              <div className="screen-content" style={{ padding: '0 16px 80px 16px' }}>
                <div className="screen-header">
                  <h3 className="screen-title">Estantería</h3>
                  <div style={{ display: 'flex', gap: '8px' }}>
                    <button style={{ border: 'none', background: 'none' }} onClick={() => setShelfFilter('favorito')}>
                      <FolderHeart size={20} color="var(--color-brown)" />
                    </button>
                    <button style={{ border: 'none', background: 'none' }} onClick={handleAddBook}>
                      <Plus size={20} />
                    </button>
                  </div>
                </div>

                {/* Sub tabs filtering */}
                <div className="shelf-tabs">
                  <button 
                    className={`shelf-tab-btn ${shelfFilter === 'leido' ? 'active' : ''}`}
                    onClick={() => setShelfFilter('leido')}
                  >
                    Leídos
                  </button>
                  <button 
                    className={`shelf-tab-btn ${shelfFilter === 'leyendo' ? 'active' : ''}`}
                    onClick={() => setShelfFilter('leyendo')}
                  >
                    Leyendo
                  </button>
                  <button 
                    className={`shelf-tab-btn ${shelfFilter === 'pendiente' ? 'active' : ''}`}
                    onClick={() => setShelfFilter('pendiente')}
                  >
                    Por leer
                  </button>
                  <button 
                    className={`shelf-tab-btn ${shelfFilter === 'favorito' ? 'active' : ''}`}
                    onClick={() => setShelfFilter('favorito')}
                  >
                    Favoritos
                  </button>
                </div>

                {/* Bookshelf Grid */}
                <div className="bookshelf-grid">
                  {books.filter(b => b.status === shelfFilter).map((book) => (
                    <div className="shelf-book-cover" key={book.id}>
                      <span style={{ fontSize: '0.65rem', padding: '4px' }}>{book.title}</span>
                      <div className="shelf-wood-plank"></div>
                    </div>
                  ))}
                  
                  {/* Add book trigger slot */}
                  <button className="shelf-add-btn" onClick={handleAddBook}>
                    <Plus size={24} />
                    <span>Añadir</span>
                  </button>
                </div>
              </div>
            )}

            {/* 6. STATISTICS SCREEN */}
            {currentScreen === 'stats' && (
              <div className="screen-content" style={{ padding: '0 16px 80px 16px' }}>
                <div className="screen-header">
                  <h3 className="screen-title">Estadísticas</h3>
                  <button style={{ border: 'none', background: 'none' }} onClick={() => setCurrentScreen('calendar')}>
                    <Calendar size={20} color="var(--color-brown)" />
                  </button>
                </div>

                <div className="shelf-tabs">
                  <button className="shelf-tab-btn active">Resumen</button>
                  <button className="shelf-tab-btn" onClick={() => setCurrentScreen('calendar')}>Tendencias</button>
                  <button className="shelf-tab-btn" onClick={() => setCurrentScreen('goals')}>Metas</button>
                </div>

                <div className="stat-grid-card" style={{ marginBottom: '16px' }}>
                  <span className="stat-grid-value" style={{ fontSize: '1.4rem' }}>Has leído 24 libros</span>
                  <span className="stat-grid-label" style={{ color: 'var(--color-green)', fontWeight: 'bold' }}>↗ 2 libros más</span>
                </div>

                <div className="stat-grid-card" style={{ marginBottom: '16px' }}>
                  <span className="stat-grid-value" style={{ fontSize: '1.4rem' }}>5,891 páginas</span>
                  <span className="stat-grid-label" style={{ color: 'var(--color-green)', fontWeight: 'bold' }}>↗ 112 páginas de progreso</span>
                </div>

                {/* Bar chart mockup */}
                <div className="stats-chart-card">
                  <h4 style={{ fontSize: '0.9rem', fontWeight: 'bold' }}>Páginas leídas por mes</h4>
                  <div className="chart-bars-container">
                    {[
                      { m: 'Mar', h: 60 },
                      { m: 'May', h: 45 },
                      { m: 'Jul', h: 90 },
                      { m: 'Sep', h: 70 },
                      { m: 'Nov', h: 80 },
                      { m: 'Ene', h: 85 },
                      { m: 'Mar25', h: 50 }
                    ].map((bar, i) => (
                      <div className="chart-bar-col" key={bar.m + i}>
                        <div className="chart-bar-fill" style={{ height: `${bar.h}px`, backgroundColor: i === 2 ? 'var(--color-brown)' : 'var(--color-blue)' }}></div>
                        <span className="chart-bar-label">{bar.m}</span>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Categories pie chart mockup */}
                <h4 style={{ fontSize: '0.9rem', color: 'var(--text-light)', marginTop: '24px', marginBottom: '12px' }}>
                  Categorías principales
                </h4>
                <div className="current-reading-card" style={{ gap: '24px', alignItems: 'center' }}>
                  <div className="pie-chart-mock">3</div>
                  <div style={{ flex: 1, fontSize: '0.8rem' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontWeight: 'bold', marginBottom: '4px' }}>
                      <span style={{ width: '8px', height: '8px', background: 'var(--color-brown)', borderRadius: '50%' }}></span>
                      <span>Ficción (45%)</span>
                    </div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--text-light)', marginBottom: '4px' }}>
                      <span style={{ width: '8px', height: '8px', background: 'var(--color-orange)', borderRadius: '50%' }}></span>
                      <span>Historia (30%)</span>
                    </div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--text-light)' }}>
                      <span style={{ width: '8px', height: '8px', background: 'var(--color-blue)', borderRadius: '50%' }}></span>
                      <span>Negocios (25%)</span>
                    </div>
                  </div>
                </div>

                {/* Achievements notification card */}
                <div className="top-indicator-card" style={{ marginTop: '20px' }}>
                  <div className="top-indicator-icon">
                    <Award size={24} />
                  </div>
                  <div>
                    <h5 className="top-indicator-title">¡Estás en el top 10%!</h5>
                    <p className="top-indicator-desc">Has leído más páginas que el 90% de los lectores este año.</p>
                  </div>
                </div>
              </div>
            )}

            {/* 7. CALENDAR SCREEN */}
            {currentScreen === 'calendar' && (
              <div className="screen-content" style={{ padding: '0 16px 80px 16px' }}>
                <div className="screen-header">
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <button style={{ background: 'none', border: 'none', cursor: 'pointer' }} onClick={() => setCurrentScreen('stats')}>
                      <ChevronLeft size={20} />
                    </button>
                    <h3 className="screen-title" style={{ fontSize: '1.2rem' }}>Calendario</h3>
                  </div>
                </div>

                <div className="calendar-month-row">
                  <button style={{ background: 'none', border: 'none' }}><ChevronLeft size={16} /></button>
                  <span className="calendar-month-title">Julio 2024</span>
                  <button style={{ background: 'none', border: 'none' }}><ChevronRight size={16} /></button>
                </div>

                <div className="calendar-days-header">
                  <span>L</span><span>M</span><span>M</span><span>J</span><span>V</span><span>S</span><span>D</span>
                </div>

                <div className="calendar-grid">
                  {Array.from({ length: 31 }, (_, i) => i + 1).map((day) => {
                    const hasBook = loggedDays.includes(day);
                    return (
                      <div 
                        className="calendar-day-cell" 
                        key={day} 
                        style={{ cursor: 'pointer' }}
                        onClick={() => toggleCalendarDay(day)}
                      >
                        <span className="calendar-day-number" style={{ color: hasBook ? 'var(--color-brown)' : 'inherit' }}>{day}</span>
                        {hasBook && (
                          <div className="calendar-day-book">
                            📖
                          </div>
                        )}
                      </div>
                    );
                  })}
                </div>

                <div className="calendar-legend">
                  <div className="legend-item">
                    <span className="legend-dot" style={{ background: 'var(--color-green)' }}></span>
                    <span>Día completado</span>
                  </div>
                  <div className="legend-item">
                    <span className="legend-dot" style={{ background: 'var(--color-blue)' }}></span>
                    <span>Libro en progreso</span>
                  </div>
                  <div className="legend-item">
                    <span className="legend-dot" style={{ background: 'var(--color-orange)' }}></span>
                    <span>Meta alcanzada</span>
                  </div>
                </div>

                <div className="period-total-card">
                  <BookOpen size={24} color="var(--color-brown)" />
                  <span style={{ fontSize: '0.8rem', fontWeight: '600' }}>
                    Has leído {books.filter(b => b.status === 'leido').length} libros y registrado {loggedDays.length} días de lectura este mes.
                  </span>
                </div>
              </div>
            )}

            {/* 8. GOALS & ACHIEVEMENTS SCREEN */}
            {currentScreen === 'goals' && (
              <div className="screen-content" style={{ padding: '0 16px 80px 16px' }}>
                <div className="screen-header">
                  <h3 className="screen-title">Metas</h3>
                  <button style={{ border: 'none', background: 'none' }} onClick={() => setCurrentScreen('premium')}>
                    <Sparkles size={20} color="var(--color-brown)" />
                  </button>
                </div>

                {/* Daily Goal */}
                <div className="stat-grid-card" style={{ padding: '16px', marginBottom: '16px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
                    <span style={{ fontWeight: 'bold', fontSize: '0.9rem' }}>Meta diaria</span>
                    <span style={{ fontSize: '0.75rem', color: 'orange', fontWeight: 'bold' }}>{currentStreakCount} días de racha 🔥</span>
                  </div>
                  <span style={{ fontSize: '0.8rem', color: 'var(--text-light)' }}>Tu meta: 30 minutos al día</span>
                  <div style={{ display: 'flex', alignItems: 'baseline', gap: '4px', margin: '12px 0 6px 0' }}>
                    <span style={{ fontSize: '1.6rem', fontFamily: 'var(--font-serif)', fontWeight: 'bold' }}>45</span>
                    <span style={{ fontSize: '0.8rem' }}>/ 30 min</span>
                  </div>
                  <div className="progress-bar-container" style={{ marginBottom: '6px' }}>
                    <div className="progress-bar-fill" style={{ width: '100%', backgroundColor: 'var(--color-green)' }}></div>
                  </div>
                  <span style={{ fontSize: '0.75rem', color: 'var(--color-green)', fontWeight: 'bold' }}>¡Meta superada! 🎉</span>
                </div>

                {/* Reading Target Year */}
                <div className="stat-grid-card" style={{ padding: '16px', marginBottom: '16px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
                    <span style={{ fontWeight: 'bold', fontSize: '0.9rem' }}>Meta de lectura</span>
                    <span style={{ fontSize: '0.75rem', color: 'var(--text-light)' }}>Este año</span>
                  </div>
                  <div style={{ display: 'flex', alignItems: 'baseline', gap: '4px', margin: '12px 0 6px 0' }}>
                    <span style={{ fontSize: '1.6rem', fontFamily: 'var(--font-serif)', fontWeight: 'bold' }}>24</span>
                    <span style={{ fontSize: '0.8rem' }}>/ 40 libros</span>
                  </div>
                  <div className="progress-bar-container" style={{ marginBottom: '6px' }}>
                    <div className="progress-bar-fill" style={{ width: '60%', backgroundColor: 'var(--color-brown)' }}></div>
                  </div>
                  <span style={{ fontSize: '0.75rem', color: 'var(--text-light)' }}>60% de la meta anual</span>
                </div>

                {/* Pages Target Year */}
                <div className="stat-grid-card" style={{ padding: '16px', marginBottom: '24px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
                    <span style={{ fontWeight: 'bold', fontSize: '0.9rem' }}>Meta de páginas</span>
                    <span style={{ fontSize: '0.75rem', color: 'var(--text-light)' }}>Este año</span>
                  </div>
                  <div style={{ display: 'flex', alignItems: 'baseline', gap: '4px', margin: '12px 0 6px 0' }}>
                    <span style={{ fontSize: '1.6rem', fontFamily: 'var(--font-serif)', fontWeight: 'bold' }}>5,891</span>
                    <span style={{ fontSize: '0.8rem' }}>/ 10,000 páginas</span>
                  </div>
                  <div className="progress-bar-container" style={{ marginBottom: '6px' }}>
                    <div className="progress-bar-fill" style={{ width: '58%', backgroundColor: 'var(--color-orange)' }}></div>
                  </div>
                  <span style={{ fontSize: '0.75rem', color: 'var(--text-light)' }}>58% completado</span>
                </div>

                {/* Achievements list */}
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
                  <h4 style={{ fontSize: '0.9rem', fontWeight: 'bold' }}>Logros</h4>
                  <button style={{ background: 'none', border: 'none', color: 'var(--color-brown)', fontWeight: 'bold', fontSize: '0.8rem' }}>Ver todos</button>
                </div>

                <div className="goals-badges-row">
                  <div className="badge-item" style={{ background: '#FFF7E6', border: '2px solid #FFA800' }}>
                    <Star size={20} color="#FFA800" fill="#FFA800" />
                  </div>
                  <div className="badge-item" style={{ background: '#F0F9FF', border: '2px solid #0091FF' }}>
                    <Award size={20} color="#0091FF" />
                  </div>
                  <div className="badge-item" style={{ background: '#ECFDF5', border: '2px solid #10B981' }}>
                    <BookOpen size={20} color="#10B981" />
                  </div>
                  <div className="badge-item" style={{ background: '#FFF1F2', border: '2px solid #F43F5E' }}>
                    <Flame size={20} color="#F43F5E" fill="#F43F5E" />
                  </div>
                </div>
              </div>
            )}

            {/* 9. PREMIUM SCREEN */}
            {currentScreen === 'premium' && (
              <div className="screen-content premium-content" style={{ padding: '20px 16px 80px 16px' }}>
                <div style={{ textAlign: 'right' }}>
                  <button style={{ border: 'none', background: 'none', cursor: 'pointer' }} onClick={() => setCurrentScreen('home')}>
                    ✕
                  </button>
                </div>

                <div className="premium-logo-area" style={{ marginTop: '10px' }}>
                  <Star size={54} color="amber" fill="amber" style={{ color: '#D4AF37' }} />
                </div>
                <h3 className="premium-title">Legibris Premium</h3>
                <p className="premium-subtitle">
                  Desbloquea las mejores herramientas de lectura e IA recomendadas por expertos.
                </p>

                <div className="premium-features-list">
                  <div className="premium-feature-item">
                    <Sparkles size={24} color="var(--color-brown)" />
                    <div className="premium-feature-info">
                      <h5 className="premium-feature-title">Asistente Lector IA</h5>
                      <p className="premium-feature-desc">Resúmenes detallados, comparaciones y planes personalizados generados por Gemini.</p>
                    </div>
                  </div>
                  
                  <div className="premium-feature-item">
                    <BarChart3 size={24} color="var(--color-brown)" />
                    <div className="premium-feature-info">
                      <h5 className="premium-feature-title">Estadísticas Avanzadas</h5>
                      <p className="premium-feature-desc">Filtros dinámicos por género, velocidad de lectura y exportación completa a PDF/CSV.</p>
                    </div>
                  </div>

                  <div className="premium-feature-item">
                    <Bookmark size={24} color="var(--color-brown)" />
                    <div className="premium-feature-info">
                      <h5 className="premium-feature-title">Diseños Exclusivos</h5>
                      <p className="premium-feature-desc">Personaliza la app con temas beige clásicos, oscuros puros y estanterías especiales.</p>
                    </div>
                  </div>
                </div>

                <div className="premium-plans">
                  <div 
                    className={`plan-card ${selectedPlan === 'mensual' ? 'selected' : ''}`}
                    onClick={() => setSelectedPlan('mensual')}
                  >
                    <div className="plan-info">
                      <span className="plan-name">Suscripción Mensual</span>
                      <p className="plan-desc">Cancela cuando quieras</p>
                    </div>
                    <span className="plan-price">$2.99</span>
                  </div>

                  <div 
                    className={`plan-card ${selectedPlan === 'anual' ? 'selected' : ''}`}
                    onClick={() => setSelectedPlan('anual')}
                  >
                    <div className="plan-info">
                      <span className="plan-name">Suscripción Anual</span>
                      <p className="plan-desc">Ahorra 20% anual</p>
                    </div>
                    <span className="plan-price">$27.99</span>
                  </div>
                </div>

                <div style={{ textAlign: 'center', margin: '12px 0', fontSize: '0.8rem', color: 'var(--color-brown)', fontWeight: 'bold' }}>
                  Pasarela: {simulatedPlatform === 'web' ? 'Web (PayPal o Mercado Pago)' : simulatedPlatform === 'android' ? 'Google Play Billing' : 'Apple In-App Purchases'}
                </div>

                <button 
                  className="btn-primary" 
                  style={{ width: '100%' }} 
                  onClick={() => triggerAlert('Suscripción', `¡Suscripción Premium procesada con éxito a través de ${simulatedPlatform === 'web' ? 'PayPal / Mercado Pago' : simulatedPlatform === 'android' ? 'Google Play Billing' : 'Apple In-App Purchases'}!`)}
                >
                  Suscribirse con {simulatedPlatform === 'web' ? 'PayPal/MercadoPago' : simulatedPlatform === 'android' ? 'Google Play' : 'Apple Pay'}
                </button>
              </div>
            )}

            {/* 10. PROFILE SCREEN */}
            {currentScreen === 'profile' && (
              <div className="screen-content" style={{ padding: '0 0 80px 0' }}>
                {/* Banner */}
                <div style={{
                  height: '140px',
                  background: 'linear-gradient(135deg, var(--color-brown) 0%, #201712 100%)',
                  position: 'relative',
                  display: 'flex',
                  alignItems: 'flex-start',
                  padding: '12px'
                }}>
                  <button 
                    style={{ background: 'rgba(255,255,255,0.2)', border: 'none', borderRadius: '50%', padding: '6px', cursor: 'pointer', display: 'flex', color: '#fff' }}
                    onClick={() => setCurrentScreen('home')}
                  >
                    <ChevronLeft size={16} />
                  </button>

                  {/* Avatar positioning */}
                  <div style={{
                    position: 'absolute',
                    bottom: '-40px',
                    left: '20px',
                    width: '80px',
                    height: '80px',
                    borderRadius: '50%',
                    background: 'var(--bg-beige)',
                    padding: '4px',
                    boxShadow: '0 4px 10px rgba(0,0,0,0.15)'
                  }}>
                    <div style={{
                      width: '100%',
                      height: '100%',
                      borderRadius: '50%',
                      background: 'var(--border-color)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      fontSize: '2rem',
                      fontWeight: 'bold',
                      color: 'var(--color-brown)'
                    }}>
                      👤
                    </div>
                  </div>
                </div>

                <div style={{ padding: '0 20px', marginTop: '50px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                    <div>
                      <h4 style={{ fontSize: '1.25rem', fontWeight: 'bold', color: 'var(--text-dark)' }}>{fullName}</h4>
                      <span style={{ fontSize: '0.8rem', color: 'var(--text-light)', fontWeight: 'bold' }}>@{username}</span>
                    </div>
                    <button style={{
                      fontSize: '0.75rem',
                      background: 'none',
                      border: '1px solid var(--color-brown)',
                      color: 'var(--color-brown)',
                      padding: '6px 12px',
                      borderRadius: '20px',
                      fontWeight: 'bold',
                      cursor: 'pointer'
                    }}>
                      Editar perfil
                    </button>
                  </div>

                  <p style={{ fontSize: '0.8rem', color: 'var(--text-light)', lineHeight: '1.4', marginTop: '12px' }}>
                    {bio}
                  </p>

                  {/* Quick stats */}
                  <div style={{
                    display: 'flex',
                    justifyContent: 'space-around',
                    background: 'var(--bg-white)',
                    border: '1px solid var(--border-color)',
                    borderRadius: '12px',
                    padding: '12px',
                    marginTop: '20px',
                    textAlign: 'center'
                  }}>
                    <div>
                      <div style={{ fontWeight: 'bold', color: 'var(--color-brown)', fontSize: '1.1rem' }}>24</div>
                      <div style={{ fontSize: '0.65rem', color: 'var(--text-light)' }}>Leídos</div>
                    </div>
                    <div>
                      <div style={{ fontWeight: 'bold', color: 'var(--color-brown)', fontSize: '1.1rem' }}>1</div>
                      <div style={{ fontSize: '0.65rem', color: 'var(--text-light)' }}>Leyendo</div>
                    </div>
                    <div>
                      <div style={{ fontWeight: 'bold', color: 'var(--color-brown)', fontSize: '1.1rem' }}>12</div>
                      <div style={{ fontSize: '0.65rem', color: 'var(--text-light)' }}>Racha Días</div>
                    </div>
                    <div>
                      <div style={{ fontWeight: 'bold', color: 'var(--color-brown)', fontSize: '1.1rem' }}>5.8k</div>
                      <div style={{ fontSize: '0.65rem', color: 'var(--text-light)' }}>Páginas</div>
                    </div>
                  </div>

                  {/* Achievements list */}
                  <h4 style={{ fontSize: '0.9rem', color: 'var(--text-light)', marginTop: '24px', marginBottom: '12px' }}>
                    Logros Recientes
                  </h4>

                  <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '12px' }}>
                    {[
                      { t: 'Primer Libro', d: 'Terminaste tu primer lectura.', c: '#FFF7E6', i: '⭐' },
                      { t: 'Racha Suprema', d: 'Leíste 10 días seguidos.', c: '#FFF1F2', i: '🔥' },
                      { t: 'Gran Lector', d: 'Completaste 10 libros.', c: '#F0F9FF', i: '🏆' },
                      { t: 'Erudito', d: 'Leíste más de 5,000 páginas.', c: '#ECFDF5', i: '📚' }
                    ].map((ach, index) => (
                      <div key={ach.t + index} style={{
                        background: 'var(--bg-white)',
                        border: '1px solid var(--border-color)',
                        borderRadius: '12px',
                        padding: '12px',
                        display: 'flex',
                        flexDirection: 'column',
                        justifyContent: 'center'
                      }}>
                        <span style={{ fontSize: '1.2rem', marginBottom: '6px' }}>{ach.i}</span>
                        <span style={{ fontWeight: 'bold', fontSize: '0.8rem' }}>{ach.t}</span>
                        <span style={{ fontSize: '0.65rem', color: 'var(--text-light)', marginTop: '2px' }}>{ach.d}</span>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            )}

            {/* Custom Alert Modal Overlay */}
            {alertModal.show && (
              <div style={{
                position: 'fixed',
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                background: 'rgba(0,0,0,0.6)',
                backdropFilter: 'blur(4px)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                padding: '24px',
                zIndex: 10000
              }}>
                <div style={{
                  background: 'var(--bg-white)',
                  borderRadius: '20px',
                  padding: '24px',
                  width: '100%',
                  maxWidth: '300px',
                  textAlign: 'center',
                  boxShadow: '0 8px 32px rgba(0,0,0,0.25)'
                }}>
                  <h4 style={{ fontSize: '1.1rem', fontWeight: 'bold', marginBottom: '8px', color: 'var(--color-brown)' }}>
                    {alertModal.title}
                  </h4>
                  <p style={{ fontSize: '0.85rem', color: 'var(--text-light)', lineHeight: '1.4', marginBottom: '20px' }}>
                    {alertModal.message}
                  </p>
                  <button 
                    className="btn-primary" 
                    style={{ width: '100%', padding: '10px' }}
                    onClick={() => setAlertModal({ ...alertModal, show: false })}
                  >
                    Aceptar
                  </button>
                </div>
              </div>
            )}

            {/* Custom Add Book Modal Overlay */}
            {addBookModal && (
              <div style={{
                position: 'fixed',
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                background: 'rgba(0,0,0,0.6)',
                backdropFilter: 'blur(4px)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                padding: '24px',
                zIndex: 10000
              }}>
                <div style={{
                  background: 'var(--bg-white)',
                  borderRadius: '20px',
                  padding: '24px',
                  width: '100%',
                  maxWidth: '320px',
                  boxShadow: '0 8px 32px rgba(0,0,0,0.25)'
                }}>
                  <h4 style={{ fontSize: '1.1rem', fontWeight: 'bold', marginBottom: '16px', color: 'var(--color-brown)', textAlign: 'center' }}>
                    Añadir Libro
                  </h4>
                  
                  <div style={{ marginBottom: '12px' }}>
                    <input 
                      type="text" 
                      placeholder="Título del libro" 
                      className="form-input"
                      style={{ paddingLeft: '16px' }}
                      value={newBookTitle}
                      onChange={(e) => setNewBookTitle(e.target.value)}
                    />
                  </div>

                  <div style={{ marginBottom: '20px' }}>
                    <input 
                      type="text" 
                      placeholder="Autor o Editorial" 
                      className="form-input"
                      style={{ paddingLeft: '16px' }}
                      value={newBookAuthor}
                      onChange={(e) => setNewBookAuthor(e.target.value)}
                    />
                  </div>

                  <div style={{ display: 'flex', gap: '12px' }}>
                    <button 
                      style={{
                        flex: 1,
                        background: 'none',
                        border: '1px solid var(--border-color)',
                        borderRadius: '10px',
                        padding: '10px',
                        cursor: 'pointer',
                        fontSize: '0.85rem',
                        fontWeight: 'bold'
                      }}
                      onClick={() => {
                        setAddBookModal(false);
                        setNewBookTitle('');
                        setNewBookAuthor('');
                      }}
                    >
                      Cancelar
                    </button>
                    <button 
                      className="btn-primary" 
                      style={{ flex: 1, padding: '10px', fontSize: '0.85rem' }}
                      onClick={submitNewBook}
                    >
                      Añadir
                    </button>
                  </div>
                </div>
              </div>
            )}

      </main>

      {/* Floating Developer Console */}
      <div className="developer-console">
        <div className="console-indicator">
          <span className="console-dot" style={{ backgroundColor: session ? '#4CAF50' : '#E67E22' }}></span>
          <span>{session ? 'Supabase Conectado' : 'Modo Sin Conexión (Offline)'}</span>
        </div>
        <div className="console-platform-selector">
          <label style={{ fontSize: '0.75rem', fontWeight: 'bold', marginRight: '6px' }}>Pasarela Activa:</label>
          <select 
            value={simulatedPlatform} 
            onChange={(e: any) => setSimulatedPlatform(e.target.value)}
            style={{
              padding: '4px 8px',
              borderRadius: '6px',
              border: '1px solid var(--border-color)',
              fontSize: '0.75rem',
              outline: 'none',
              cursor: 'pointer'
            }}
          >
            <option value="web">💻 Web (PayPal / Mercado Pago)</option>
            <option value="android">🤖 Android (Google Play Billing)</option>
            <option value="ios">🍎 iOS (Apple In-App Purchases)</option>
          </select>
        </div>
        {session && (
          <button 
            className="console-logout-btn" 
            onClick={handleSupabaseLogout}
            style={{
              background: 'none',
              border: 'none',
              color: 'var(--color-brown)',
              fontWeight: 'bold',
              fontSize: '0.75rem',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '4px',
              marginTop: '4px',
              padding: 0
            }}
          >
            <LogOut size={12} /> Cerrar Sesión Supabase
          </button>
        )}
      </div>

    </div>
  );
}
