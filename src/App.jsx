import React, { useEffect, useMemo, useState } from 'react';
import {
  AlertCircle,
  ArrowLeft,
  ArrowRight,
  BookOpen,
  CheckCircle2,
  Clock3,
  Database,
  Eye,
  Flag,
  History,
  LogIn,
  LogOut,
  Menu,
  Pencil,
  Plus,
  RotateCcw,
  Save,
  Send,
  Trash2,
  Upload,
  X,
} from 'lucide-react';
import { examConfig as localExamConfig, questions as localQuestions } from './questions.js';
import { isSupabaseConfigured, supabase } from './supabaseClient.js';

const HISTORY_STORAGE_KEY = 'cbt-bank-soal-local-attempts';

const screen = {
  LOGIN: 'login',
  INSTRUCTIONS: 'instructions',
  EXAM: 'exam',
  RESULT: 'result',
  REVIEW: 'review',
  ADMIN: 'admin',
};

const emptyQuestionForm = {
  id: null,
  exam_id: '',
  sort_order: 1,
  text: '',
  image: '',
  options: { A: '', B: '', C: '', D: '', E: '' },
  answer: 'A',
  active: true,
};

const emptyExamForm = {
  id: null,
  title: '',
  subject: 'Simulasi Pengetahuan Umum',
  duration_minutes: 120,
  active: true,
};

function formatTime(totalSeconds) {
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;
  return [hours, minutes, seconds].map((value) => String(value).padStart(2, '0')).join(':');
}

function formatDateTime(value) {
  if (!value) return '-';
  return new Intl.DateTimeFormat('id-ID', {
    dateStyle: 'medium',
    timeStyle: 'short',
  }).format(new Date(value));
}

function normalizeQuestion(question, index) {
  return {
    id: question.id ?? String(question.sort_order ?? index + 1),
    exam_id: question.exam_id || 'local-day-10',
    sort_order: question.sort_order ?? index + 1,
    text: question.text,
    image: question.image || '',
    options: question.options || {},
    answer: question.answer,
    active: question.active ?? true,
  };
}

function normalizeExam(exam) {
  return {
    id: exam.id,
    title: exam.title,
    subject: exam.subject,
    durationMinutes: exam.duration_minutes ?? exam.durationMinutes ?? 120,
    active: exam.active ?? true,
  };
}

function getLocalQuestions() {
  return localQuestions.map((question, index) => normalizeQuestion({ ...question, exam_id: 'local-day-10', sort_order: index + 1 }, index));
}

function getLocalExams() {
  return [{ id: 'local-day-10', title: localExamConfig.title, subject: localExamConfig.subject, durationMinutes: localExamConfig.durationMinutes, active: true }];
}

function getLocalAttempts() {
  try {
    return JSON.parse(window.localStorage.getItem(HISTORY_STORAGE_KEY) || '[]');
  } catch {
    return [];
  }
}

function calculateResult(questionBank, answers) {
  return questionBank.reduce(
    (acc, question) => {
      const chosen = answers[question.id];
      if (!chosen) {
        acc.unanswered += 1;
      } else if (chosen === question.answer) {
        acc.correct += 1;
      } else {
        acc.wrong += 1;
      }
      return acc;
    },
    { correct: 0, wrong: 0, unanswered: 0 },
  );
}

function questionToForm(question) {
  return {
    id: question.id,
    exam_id: question.exam_id,
    sort_order: question.sort_order,
    text: question.text,
    image: question.image || '',
    options: {
      A: question.options?.A || '',
      B: question.options?.B || '',
      C: question.options?.C || '',
      D: question.options?.D || '',
      E: question.options?.E || '',
    },
    answer: question.answer || 'A',
    active: question.active ?? true,
  };
}

function formToPayload(form) {
  const options = Object.fromEntries(
    Object.entries(form.options)
      .map(([key, value]) => [key, value.trim()])
      .filter(([, value]) => value),
  );

  return {
    exam_id: form.exam_id,
    sort_order: Number(form.sort_order),
    text: form.text.trim(),
    image: form.image.trim(),
    options,
    answer: form.answer,
    active: Boolean(form.active),
  };
}

function App() {
  const [page, setPage] = useState(screen.LOGIN);
  const [loginMode, setLoginMode] = useState('regu');
  const [exams, setExams] = useState(getLocalExams);
  const [selectedExamId, setSelectedExamId] = useState('local-day-10');
  const [settings, setSettings] = useState(localExamConfig);
  const [questionBank, setQuestionBank] = useState(getLocalQuestions);
  const [loadingData, setLoadingData] = useState(true);
  const [dataMessage, setDataMessage] = useState('');

  const [participant, setParticipant] = useState({ name: '', number: '' });
  const [currentIndex, setCurrentIndex] = useState(0);
  const [answers, setAnswers] = useState({});
  const [doubtful, setDoubtful] = useState({});
  const [secondsLeft, setSecondsLeft] = useState(localExamConfig.durationMinutes * 60);
  const [examStartedAt, setExamStartedAt] = useState(null);
  const [showSubmitConfirm, setShowSubmitConfirm] = useState(false);
  const [showMobilePanel, setShowMobilePanel] = useState(false);
  const [result, setResult] = useState(null);
  const [saveStatus, setSaveStatus] = useState('');

  const [adminSession, setAdminSession] = useState(null);
  const [isAdmin, setIsAdmin] = useState(false);
  const [adminAuth, setAdminAuth] = useState({ email: '', password: '' });
  const [adminMessage, setAdminMessage] = useState('');
  const [adminExams, setAdminExams] = useState([]);
  const [selectedAdminExamId, setSelectedAdminExamId] = useState('');
  const [adminQuestions, setAdminQuestions] = useState([]);
  const [attempts, setAttempts] = useState([]);
  const [selectedAttempt, setSelectedAttempt] = useState(null);
  const [questionForm, setQuestionForm] = useState(emptyQuestionForm);
  const [settingsForm, setSettingsForm] = useState({
    id: null,
    title: localExamConfig.title,
    subject: localExamConfig.subject,
    duration_minutes: localExamConfig.durationMinutes,
    active: true,
  });

  const currentQuestion = questionBank[currentIndex];
  const answeredCount = Object.keys(answers).length;
  const doubtfulCount = Object.values(doubtful).filter(Boolean).length;

  useEffect(() => {
    loadPublicData();
    restoreAdminSession();
  }, []);

  useEffect(() => {
    setSecondsLeft((settings.durationMinutes || 120) * 60);
    setSettingsForm({
      id: selectedExamId,
      title: settings.title,
      subject: settings.subject,
      duration_minutes: settings.durationMinutes,
      active: settings.active ?? true,
    });
  }, [settings, selectedExamId]);

  useEffect(() => {
    if (page !== screen.EXAM) return undefined;
    if (secondsLeft <= 0) {
      finishExam();
      return undefined;
    }
    const interval = window.setInterval(() => {
      setSecondsLeft((value) => Math.max(value - 1, 0));
    }, 1000);
    return () => window.clearInterval(interval);
  }, [page, secondsLeft]);

  const summary = useMemo(() => calculateResult(questionBank, answers), [answers, questionBank]);

  async function loadPublicData(targetExamId = selectedExamId) {
    setLoadingData(true);
    setDataMessage('');

    if (!isSupabaseConfigured) {
      setExams(getLocalExams());
      setSelectedExamId('local-day-10');
      setQuestionBank(getLocalQuestions());
      setSettings(localExamConfig);
      setDataMessage('Supabase belum dikonfigurasi. Aplikasi memakai data lokal.');
      setLoadingData(false);
      return;
    }

    const { data: examRows, error: examsError } = await supabase
      .from('exams')
      .select('*')
      .eq('active', true)
      .order('created_at', { ascending: true });

    if (examsError || !examRows?.length) {
      const [{ data: settingsRows }, { data: rows }] = await Promise.all([
        supabase.from('exam_settings').select('*').eq('id', 1).maybeSingle(),
        supabase.from('questions').select('*').eq('active', true).order('sort_order', { ascending: true }),
      ]);
      if (settingsRows && rows) {
        setExams([{ id: 'legacy', title: settingsRows.title, subject: settingsRows.subject, durationMinutes: settingsRows.duration_minutes, active: true }]);
        setSelectedExamId('legacy');
        setSettings({
          title: settingsRows.title,
          subject: settingsRows.subject,
          durationMinutes: settingsRows.duration_minutes,
          active: true,
        });
        setQuestionBank((rows || []).map(normalizeQuestion));
        setDataMessage('Database masih memakai schema lama. Jalankan migration multi-paket agar admin bisa membuat Day 11.');
        setLoadingData(false);
        return;
      }
      setQuestionBank(getLocalQuestions());
      setSettings(localExamConfig);
      setExams(getLocalExams());
      setSelectedExamId('local-day-10');
      setDataMessage('Belum bisa membaca Supabase. Jalankan supabase/schema.sql terlebih dahulu, sementara aplikasi memakai data lokal.');
      setLoadingData(false);
      return;
    }

    const normalizedExams = examRows.map(normalizeExam);
    const chosenExam = normalizedExams.find((exam) => exam.id === targetExamId) || normalizedExams[0];
    const { data: rows, error: questionsError } = await supabase
      .from('questions')
      .select('*')
      .eq('exam_id', chosenExam.id)
      .eq('active', true)
      .order('sort_order', { ascending: true });

    if (questionsError) {
      setDataMessage(`Gagal memuat soal: ${questionsError.message}`);
      setLoadingData(false);
      return;
    }

    setExams(normalizedExams);
    setSelectedExamId(chosenExam.id);
    setSettings(chosenExam);
    setQuestionBank((rows || []).map(normalizeQuestion));
    setDataMessage('');
    setLoadingData(false);
  }

  async function selectExam(examId) {
    setSelectedExamId(examId);
    await loadPublicData(examId);
    setCurrentIndex(0);
    setAnswers({});
    setDoubtful({});
    setResult(null);
  }

  async function restoreAdminSession() {
    if (!isSupabaseConfigured) return;
    const { data } = await supabase.auth.getSession();
    if (data.session) {
      setAdminSession(data.session);
      await checkAdminAccess(data.session.user);
    }
  }

  async function checkAdminAccess(user) {
    const { data, error } = await supabase.from('admin_profiles').select('user_id').eq('user_id', user.id).maybeSingle();
    const allowed = Boolean(data && !error);
    setIsAdmin(allowed);
    if (allowed) {
      await loadAdminData();
    } else {
      setAdminMessage('Akun ini sudah login, tetapi belum ditandai sebagai admin di tabel admin_profiles.');
    }
  }

  async function loadAdminData(targetExamId = selectedAdminExamId) {
    if (!isSupabaseConfigured) return;
    const { data: examRows } = await supabase.from('exams').select('*').order('created_at', { ascending: true });
    const normalizedExams = (examRows || []).map(normalizeExam);
    const activeExamId = targetExamId || normalizedExams[0]?.id || '';
    const [{ data: questionRows }, { data: attemptRows }] = await Promise.all([
      activeExamId
        ? supabase.from('questions').select('*').eq('exam_id', activeExamId).order('sort_order', { ascending: true })
        : Promise.resolve({ data: [] }),
      supabase.from('attempts').select('*').order('finished_at', { ascending: false }),
    ]);
    setAdminExams(normalizedExams);
    setSelectedAdminExamId(activeExamId);
    setAdminQuestions((questionRows || []).map(normalizeQuestion));
    setAttempts(attemptRows || []);
    if (!questionForm.exam_id && activeExamId) {
      setQuestionForm((form) => ({ ...form, exam_id: activeExamId }));
    }
  }

  function startInstructions(event) {
    event.preventDefault();
    if (questionBank.length === 0) {
      window.alert('Belum ada soal aktif. Tambahkan soal dari halaman admin terlebih dahulu.');
      return;
    }
    setPage(screen.INSTRUCTIONS);
  }

  function startExam() {
    setPage(screen.EXAM);
    setSecondsLeft((settings.durationMinutes || 120) * 60);
    setExamStartedAt(new Date().toISOString());
  }

  function chooseAnswer(optionKey) {
    setAnswers((previous) => ({ ...previous, [currentQuestion.id]: optionKey }));
  }

  function toggleDoubtful() {
    setDoubtful((previous) => ({ ...previous, [currentQuestion.id]: !previous[currentQuestion.id] }));
  }

  function goToQuestion(index) {
    setCurrentIndex(index);
    setShowMobilePanel(false);
  }

  async function finishExam() {
    const finishedAt = new Date().toISOString();
    const finalSummary = calculateResult(questionBank, answers);
    const finalResult = {
      ...finalSummary,
      score: Math.round((finalSummary.correct / questionBank.length) * 100),
      total: questionBank.length,
    };
    const durationSeconds = Math.max((settings.durationMinutes || 120) * 60 - secondsLeft, 0);

    const payload = {
      exam_id: selectedExamId === 'legacy' || selectedExamId === 'local-day-10' ? null : selectedExamId,
      team_name: participant.name,
      team_number: participant.number,
      exam_title: settings.title,
      started_at: examStartedAt || finishedAt,
      finished_at: finishedAt,
      duration_seconds: durationSeconds,
      score: finalResult.score,
      correct_count: finalResult.correct,
      wrong_count: finalResult.wrong,
      unanswered_count: finalResult.unanswered,
      total_questions: finalResult.total,
      answers,
      doubtful,
      question_snapshot: questionBank,
    };

    setSaveStatus('Menyimpan hasil...');
    if (isSupabaseConfigured) {
      const { error } = await supabase.from('attempts').insert(payload);
      setSaveStatus(error ? `Hasil tampil, tetapi gagal tersimpan ke Supabase: ${error.message}` : 'Hasil berhasil tersimpan ke database.');
    } else {
      const localAttempt = { ...payload, id: `${Date.now()}`, result: finalResult };
      const nextHistory = [localAttempt, ...getLocalAttempts()].slice(0, 200);
      window.localStorage.setItem(HISTORY_STORAGE_KEY, JSON.stringify(nextHistory));
      setSaveStatus('Hasil tersimpan lokal di browser ini.');
    }

    setResult(finalResult);
    setShowSubmitConfirm(false);
    setPage(screen.RESULT);
  }

  function restart() {
    setPage(screen.LOGIN);
    setParticipant({ name: '', number: '' });
    setCurrentIndex(0);
    setAnswers({});
    setDoubtful({});
    setSecondsLeft((settings.durationMinutes || 120) * 60);
    setExamStartedAt(null);
    setShowSubmitConfirm(false);
    setShowMobilePanel(false);
    setResult(null);
    setSaveStatus('');
  }

  async function adminSignIn(event) {
    event.preventDefault();
    setAdminMessage('Memproses login...');
    const { data, error } = await supabase.auth.signInWithPassword(adminAuth);
    if (error) {
      setAdminMessage(error.message);
      return;
    }
    setAdminSession(data.session);
    await checkAdminAccess(data.user);
  }

  async function adminSignUp() {
    setAdminMessage('Membuat akun admin...');
    const { data, error } = await supabase.auth.signUp(adminAuth);
    if (error) {
      setAdminMessage(error.message);
      return;
    }
    setAdminMessage(`Akun dibuat. Copy User UID ini ke SQL admin_profiles: ${data.user?.id || 'cek Authentication > Users'}`);
  }

  async function adminLogout() {
    await supabase.auth.signOut();
    setAdminSession(null);
    setIsAdmin(false);
    setAdminMessage('');
    setAttempts([]);
    setAdminQuestions([]);
  }

  async function saveSettings(event) {
    event.preventDefault();
    const payload = {
      title: settingsForm.title.trim(),
      subject: settingsForm.subject.trim(),
      duration_minutes: Number(settingsForm.duration_minutes),
      active: Boolean(settingsForm.active),
      updated_at: new Date().toISOString(),
    };
    const query = settingsForm.id
      ? supabase.from('exams').update(payload).eq('id', settingsForm.id)
      : supabase.from('exams').insert(payload).select('*').single();
    const { data, error } = await query;
    const savedExamId = settingsForm.id || data?.id;
    setAdminMessage(error ? error.message : 'Paket soal berhasil disimpan.');
    if (!error) {
      setSelectedAdminExamId(savedExamId);
      setSettingsForm({ ...payload, id: savedExamId });
      await loadAdminData(savedExamId);
      await loadPublicData(selectedExamId);
    }
  }

  function newExam() {
    setSettingsForm({ ...emptyExamForm });
    setQuestionForm({ ...emptyQuestionForm, exam_id: selectedAdminExamId, sort_order: adminQuestions.length + 1 });
  }

  async function selectAdminExam(examId) {
    const exam = adminExams.find((item) => item.id === examId);
    setSelectedAdminExamId(examId);
    if (exam) {
      setSettingsForm({
        id: exam.id,
        title: exam.title,
        subject: exam.subject,
        duration_minutes: exam.durationMinutes,
        active: exam.active,
      });
    }
    setQuestionForm({ ...emptyQuestionForm, exam_id: examId, sort_order: 1 });
    const { data: questionRows } = await supabase.from('questions').select('*').eq('exam_id', examId).order('sort_order', { ascending: true });
    setAdminQuestions((questionRows || []).map(normalizeQuestion));
  }

  async function deleteExam(id) {
    if (adminExams.length <= 1) {
      setAdminMessage('Tidak bisa menghapus satu-satunya paket soal. Buat paket lain terlebih dahulu.');
      return;
    }
    const exam = adminExams.find((item) => item.id === id);
    const confirmed = window.confirm(`Hapus permanen paket "${exam?.title || 'ini'}" beserta semua soalnya? Nilai yang sudah masuk tetap tersimpan.`);
    if (!confirmed) return;
    setAdminMessage('Menghapus paket soal...');

    const { error: detachAttemptsError } = await supabase.from('attempts').update({ exam_id: null }).eq('exam_id', id);
    if (detachAttemptsError) {
      setAdminMessage(`Gagal melepas nilai dari paket: ${detachAttemptsError.message}`);
      return;
    }

    const { error: deleteQuestionsError } = await supabase.from('questions').delete().eq('exam_id', id);
    if (deleteQuestionsError) {
      setAdminMessage(`Gagal menghapus soal dalam paket: ${deleteQuestionsError.message}`);
      return;
    }

    const { error } = await supabase.from('exams').delete().eq('id', id);
    setAdminMessage(error ? `Gagal menghapus paket: ${error.message}` : 'Paket soal berhasil dihapus.');
    if (!error) {
      setSelectedAdminExamId('');
      setSettingsForm({ ...emptyExamForm });
      setQuestionForm({ ...emptyQuestionForm });
      await loadAdminData();
      await loadPublicData();
    }
  }

  async function saveQuestion(event) {
    event.preventDefault();
    const payload = formToPayload({ ...questionForm, exam_id: questionForm.exam_id || selectedAdminExamId });
    if (!payload.text || !payload.options[payload.answer]) {
      setAdminMessage('Teks soal dan opsi jawaban benar wajib diisi.');
      return;
    }
    if (!payload.exam_id) {
      setAdminMessage('Pilih atau buat paket soal terlebih dahulu.');
      return;
    }

    const query = questionForm.id
      ? supabase.from('questions').update({ ...payload, updated_at: new Date().toISOString() }).eq('id', questionForm.id)
      : supabase.from('questions').insert(payload);
    const { error } = await query;
    setAdminMessage(error ? error.message : 'Soal berhasil disimpan.');
    if (!error) {
      setQuestionForm({ ...emptyQuestionForm, exam_id: payload.exam_id, sort_order: adminQuestions.length + 1 });
      await loadAdminData();
      await loadPublicData();
    }
  }

  async function uploadQuestionImage(file) {
    if (!file) return;
    if (!questionForm.exam_id && !selectedAdminExamId) {
      setAdminMessage('Pilih paket soal sebelum upload gambar.');
      return;
    }
    const safeName = file.name.toLowerCase().replace(/[^a-z0-9.]+/g, '-');
    const path = `${questionForm.exam_id || selectedAdminExamId}/${Date.now()}-${safeName}`;
    setAdminMessage('Mengupload gambar...');
    const { error } = await supabase.storage.from('question-images').upload(path, file, { upsert: false });
    if (error) {
      setAdminMessage(error.message);
      return;
    }
    const { data } = supabase.storage.from('question-images').getPublicUrl(path);
    setQuestionForm((form) => ({ ...form, image: data.publicUrl }));
    setAdminMessage('Gambar berhasil diupload.');
  }

  async function deleteQuestion(id) {
    const confirmed = window.confirm('Hapus soal ini?');
    if (!confirmed) return;
    const { error } = await supabase.from('questions').delete().eq('id', id);
    setAdminMessage(error ? error.message : 'Soal berhasil dihapus.');
    if (!error) {
      await loadAdminData();
      await loadPublicData();
    }
  }

  async function deleteAttempt(id) {
    const confirmed = window.confirm('Hapus nilai regu ini?');
    if (!confirmed) return;
    const { error } = await supabase.from('attempts').delete().eq('id', id);
    setAdminMessage(error ? error.message : 'Nilai berhasil dihapus.');
    if (!error) {
      setSelectedAttempt(null);
      await loadAdminData();
    }
  }

  if (loadingData) {
    return (
      <Shell centered>
        <div className="rounded-lg border border-slate-200 bg-white p-6 text-center shadow-soft">
          <Clock3 className="mx-auto text-blue-700" size={28} aria-hidden="true" />
          <p className="mt-4 font-semibold text-slate-800">Memuat bank soal...</p>
        </div>
      </Shell>
    );
  }

  if (page === screen.LOGIN) {
    return (
      <Shell centered>
        <section className="w-full max-w-md rounded-lg border border-slate-200 bg-white p-6 shadow-soft sm:p-8">
          <div className="mb-8">
            <div className="mb-5 flex h-12 w-12 items-center justify-center rounded-md bg-blue-600 text-white">
              <BookOpen size={26} aria-hidden="true" />
            </div>
            <p className="text-sm font-semibold uppercase tracking-[0.18em] text-blue-700">CBT Simulasi Bank Soal</p>
            <h1 className="mt-2 text-2xl font-bold text-slate-950 sm:text-3xl">{loginMode === 'regu' ? 'Login Regu' : 'Panel Admin'}</h1>
            {dataMessage ? <p className="mt-2 rounded-md bg-yellow-50 p-3 text-sm leading-6 text-yellow-800">{dataMessage}</p> : null}
          </div>

          <div className="mb-5 grid grid-cols-2 gap-2 rounded-lg bg-slate-100 p-1">
            <button
              onClick={() => setLoginMode('regu')}
              className={`rounded-md px-3 py-2 text-sm font-bold ${loginMode === 'regu' ? 'bg-white text-blue-700 shadow-sm' : 'text-slate-600'}`}
            >
              Regu
            </button>
            <button
              onClick={() => {
                setLoginMode('admin');
                setPage(screen.ADMIN);
              }}
              className={`rounded-md px-3 py-2 text-sm font-bold ${loginMode === 'admin' ? 'bg-white text-blue-700 shadow-sm' : 'text-slate-600'}`}
            >
              Admin
            </button>
          </div>

          <form className="space-y-4" onSubmit={startInstructions}>
            <label className="block">
              <span className="text-sm font-semibold text-slate-700">Pilih paket soal</span>
              <select
                value={selectedExamId}
                onChange={(event) => selectExam(event.target.value)}
                className="mt-2 w-full rounded-md border border-slate-300 px-4 py-3 text-slate-900 outline-none transition focus:border-blue-600 focus:ring-4 focus:ring-blue-100"
              >
                {exams.map((exam) => (
                  <option key={exam.id} value={exam.id}>
                    {exam.title}
                  </option>
                ))}
              </select>
            </label>
            <label className="block">
              <span className="text-sm font-semibold text-slate-700">Nama regu</span>
              <input
                required
                value={participant.name}
                onChange={(event) => setParticipant((value) => ({ ...value, name: event.target.value }))}
                className="mt-2 w-full rounded-md border border-slate-300 px-4 py-3 text-slate-900 outline-none transition focus:border-blue-600 focus:ring-4 focus:ring-blue-100"
                placeholder="Contoh: Regu Garuda"
              />
            </label>
            <label className="block">
              <span className="text-sm font-semibold text-slate-700">Nomor regu</span>
              <input
                required
                value={participant.number}
                onChange={(event) => setParticipant((value) => ({ ...value, number: event.target.value }))}
                className="mt-2 w-full rounded-md border border-slate-300 px-4 py-3 text-slate-900 outline-none transition focus:border-blue-600 focus:ring-4 focus:ring-blue-100"
                placeholder="Contoh: 01"
              />
            </label>
            <button className="flex w-full items-center justify-center gap-2 rounded-md bg-blue-700 px-4 py-3 font-semibold text-white transition hover:bg-blue-800 focus:outline-none focus:ring-4 focus:ring-blue-200">
              <LogIn size={19} aria-hidden="true" />
              Masuk
            </button>
          </form>
        </section>
      </Shell>
    );
  }

  if (page === screen.ADMIN) {
    return (
      <AdminPage
        adminAuth={adminAuth}
        adminMessage={adminMessage}
        adminQuestions={adminQuestions}
        adminSession={adminSession}
        attempts={attempts}
        deleteAttempt={deleteAttempt}
        deleteQuestion={deleteQuestion}
        isAdmin={isAdmin}
        onBack={() => {
          setLoginMode('regu');
          setPage(screen.LOGIN);
        }}
        onLogin={adminSignIn}
        onLogout={adminLogout}
        onSignup={adminSignUp}
        questionForm={questionForm}
        saveQuestion={saveQuestion}
        saveSettings={saveSettings}
        selectedAdminExamId={selectedAdminExamId}
        selectedAttempt={selectedAttempt}
        setAdminAuth={setAdminAuth}
        setQuestionForm={setQuestionForm}
        setSelectedAttempt={setSelectedAttempt}
        setSettingsForm={setSettingsForm}
        settingsForm={settingsForm}
        adminExams={adminExams}
        deleteExam={deleteExam}
        newExam={newExam}
        selectAdminExam={selectAdminExam}
        uploadQuestionImage={uploadQuestionImage}
      />
    );
  }

  if (page === screen.INSTRUCTIONS) {
    return (
      <Shell>
        <main className="mx-auto flex min-h-screen w-full max-w-5xl items-center px-4 py-8">
          <section className="w-full rounded-lg border border-slate-200 bg-white shadow-soft">
            <div className="border-b border-slate-200 p-5 sm:p-7">
              <p className="text-sm font-semibold text-blue-700">{settings.subject}</p>
              <h1 className="mt-2 text-2xl font-bold text-slate-950 sm:text-3xl">{settings.title}</h1>
              <div className="mt-4 grid gap-3 text-sm text-slate-600 sm:grid-cols-3">
                <Info label="Regu" value={participant.name} />
                <Info label="Nomor Regu" value={participant.number} />
                <Info label="Durasi" value={`${settings.durationMinutes} menit`} />
              </div>
            </div>
            <div className="grid gap-6 p-5 sm:p-7 lg:grid-cols-[1fr_280px]">
              <div>
                <h2 className="text-lg font-bold text-slate-950">Instruksi Ujian</h2>
                <ol className="mt-4 space-y-3 text-sm leading-6 text-slate-700">
                  <li>1. Bacalah setiap soal dengan teliti sebelum memilih jawaban.</li>
                  <li>2. Pilih satu jawaban dari opsi yang tersedia.</li>
                  <li>3. Gunakan tombol ragu-ragu untuk menandai soal yang ingin ditinjau ulang.</li>
                  <li>4. Nomor soal berwarna biru berarti sudah dijawab, kuning berarti ragu-ragu, dan putih berarti belum dijawab.</li>
                  <li>5. Ujian akan otomatis selesai ketika timer mencapai 00:00:00.</li>
                </ol>
              </div>
              <aside className="rounded-lg border border-blue-100 bg-blue-50 p-5">
                <div className="flex items-center gap-3 text-blue-900">
                  <Clock3 size={22} aria-hidden="true" />
                  <div>
                    <p className="text-sm font-semibold">Waktu tersedia</p>
                    <p className="text-2xl font-bold">{settings.durationMinutes}:00</p>
                  </div>
                </div>
                <button
                  onClick={startExam}
                  className="mt-6 flex w-full items-center justify-center gap-2 rounded-md bg-blue-700 px-4 py-3 font-semibold text-white transition hover:bg-blue-800 focus:outline-none focus:ring-4 focus:ring-blue-200"
                >
                  Mulai Ujian
                  <ArrowRight size={18} aria-hidden="true" />
                </button>
              </aside>
            </div>
          </section>
        </main>
      </Shell>
    );
  }

  if (page === screen.RESULT && result) {
    return (
      <Shell centered>
        <section className="w-full max-w-3xl rounded-lg border border-slate-200 bg-white p-6 shadow-soft sm:p-8">
          <div className="flex flex-col gap-5 border-b border-slate-200 pb-6 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <p className="text-sm font-semibold text-blue-700">Hasil Ujian</p>
              <h1 className="mt-2 text-2xl font-bold text-slate-950 sm:text-3xl">{participant.name}</h1>
              <p className="mt-1 text-sm text-slate-600">Nomor regu: {participant.number}</p>
              {saveStatus ? <p className="mt-3 rounded-md bg-slate-50 p-3 text-sm text-slate-600">{saveStatus}</p> : null}
            </div>
            <div className="rounded-lg bg-blue-700 px-6 py-4 text-center text-white">
              <p className="text-sm font-semibold text-blue-100">Skor</p>
              <p className="text-4xl font-bold">{result.score}</p>
            </div>
          </div>
          <div className="mt-6 grid gap-3 sm:grid-cols-4">
            <ResultCard label="Benar" value={result.correct} tone="green" />
            <ResultCard label="Salah" value={result.wrong} tone="red" />
            <ResultCard label="Tidak Dijawab" value={result.unanswered} tone="slate" />
            <ResultCard label="Total Soal" value={result.total} tone="blue" />
          </div>
          <div className="mt-7 flex flex-col gap-3 sm:flex-row">
            <button
              onClick={() => setPage(screen.REVIEW)}
              className="flex w-full items-center justify-center gap-2 rounded-md bg-blue-700 px-4 py-3 font-semibold text-white transition hover:bg-blue-800 focus:outline-none focus:ring-4 focus:ring-blue-200 sm:w-auto"
            >
              <CheckCircle2 size={18} aria-hidden="true" />
              Lihat Koreksi Jawaban
            </button>
            <button
              onClick={restart}
              className="flex w-full items-center justify-center gap-2 rounded-md border border-slate-300 bg-white px-4 py-3 font-semibold text-slate-800 transition hover:bg-slate-50 focus:outline-none focus:ring-4 focus:ring-blue-100 sm:w-auto"
            >
              <RotateCcw size={18} aria-hidden="true" />
              Ulangi Simulasi
            </button>
          </div>
        </section>
      </Shell>
    );
  }

  if (page === screen.REVIEW && result) {
    return (
      <ReviewPage
        answers={answers}
        attempt={null}
        backLabel="Kembali ke Hasil"
        onBack={() => setPage(screen.RESULT)}
        onRestart={restart}
        questionSource={questionBank}
        result={result}
        subtitle={`${participant.name} - Skor ${result.score}`}
        title="Rincian Hasil Ujian"
      />
    );
  }

  return (
    <Shell>
      <div className="flex min-h-screen flex-col bg-slate-100">
        <header className="sticky top-0 z-30 border-b border-slate-200 bg-white">
          <div className="flex min-h-16 items-center justify-between gap-3 px-4 py-3 lg:px-6">
            <div className="flex min-w-0 items-center gap-3">
              <button
                onClick={() => setShowMobilePanel(true)}
                className="inline-flex h-10 w-10 items-center justify-center rounded-md border border-slate-300 text-slate-700 lg:hidden"
                aria-label="Buka daftar soal"
              >
                <Menu size={20} aria-hidden="true" />
              </button>
              <div className="min-w-0">
                <p className="truncate text-sm font-semibold text-blue-700">{settings.subject}</p>
                <h1 className="truncate text-base font-bold text-slate-950 sm:text-lg">{settings.title}</h1>
              </div>
            </div>
            <div className="flex items-center gap-2 rounded-md border border-blue-200 bg-blue-50 px-3 py-2 text-blue-900">
              <Clock3 size={18} aria-hidden="true" />
              <span className="min-w-[78px] text-right font-mono text-sm font-bold sm:text-base">{formatTime(secondsLeft)}</span>
            </div>
          </div>
        </header>

        <div className="grid flex-1 lg:grid-cols-[280px_1fr]">
          <QuestionPanel
            answers={answers}
            currentIndex={currentIndex}
            doubtful={doubtful}
            goToQuestion={goToQuestion}
            isMobile={false}
            questions={questionBank}
          />

          <main className="min-w-0 p-4 lg:p-6">
            <section className="mx-auto max-w-5xl rounded-lg border border-slate-200 bg-white shadow-soft">
              <div className="border-b border-slate-200 p-4 sm:p-6">
                <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
                  <div>
                    <p className="text-sm font-semibold text-slate-500">Soal {currentIndex + 1} dari {questionBank.length}</p>
                    <h2 className="mt-2 text-lg font-bold leading-7 text-slate-950 sm:text-xl">{currentQuestion.text}</h2>
                  </div>
                  <StatusPill answered={Boolean(answers[currentQuestion.id])} doubtful={Boolean(doubtful[currentQuestion.id])} />
                </div>
                {currentQuestion.image ? (
                  <img
                    src={currentQuestion.image}
                    alt={`Ilustrasi soal ${currentIndex + 1}`}
                    className="mt-5 max-h-80 w-full rounded-md border border-slate-200 object-contain"
                  />
                ) : null}
              </div>

              <div className="space-y-3 p-4 sm:p-6">
                {Object.entries(currentQuestion.options).map(([key, value]) => {
                  const selected = answers[currentQuestion.id] === key;
                  return (
                    <button
                      key={key}
                      onClick={() => chooseAnswer(key)}
                      className={`flex w-full items-start gap-3 rounded-md border p-4 text-left transition focus:outline-none focus:ring-4 focus:ring-blue-100 ${
                        selected
                          ? 'border-blue-600 bg-blue-50 text-blue-950'
                          : 'border-slate-200 bg-white text-slate-700 hover:border-blue-300 hover:bg-slate-50'
                      }`}
                    >
                      <span className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-md text-sm font-bold ${selected ? 'bg-blue-700 text-white' : 'bg-slate-100 text-slate-700'}`}>
                        {key}
                      </span>
                      <span className="pt-1 text-sm leading-6 sm:text-base">{value}</span>
                    </button>
                  );
                })}
              </div>

              <div className="flex flex-col gap-3 border-t border-slate-200 p-4 sm:flex-row sm:items-center sm:justify-between sm:p-6">
                <button
                  onClick={toggleDoubtful}
                  className={`flex items-center justify-center gap-2 rounded-md border px-4 py-3 font-semibold transition focus:outline-none focus:ring-4 focus:ring-yellow-100 ${
                    doubtful[currentQuestion.id]
                      ? 'border-yellow-300 bg-yellow-100 text-yellow-900'
                      : 'border-slate-300 bg-white text-slate-800 hover:bg-slate-50'
                  }`}
                >
                  <Flag size={18} aria-hidden="true" />
                  Tandai Ragu-ragu
                </button>
                <div className="grid grid-cols-2 gap-3 sm:flex">
                  <button
                    onClick={() => goToQuestion(Math.max(currentIndex - 1, 0))}
                    disabled={currentIndex === 0}
                    className="flex items-center justify-center gap-2 rounded-md border border-slate-300 bg-white px-4 py-3 font-semibold text-slate-800 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-45"
                  >
                    <ArrowLeft size={18} aria-hidden="true" />
                    Sebelumnya
                  </button>
                  {currentIndex === questionBank.length - 1 ? (
                    <button
                      onClick={() => setShowSubmitConfirm(true)}
                      className="flex items-center justify-center gap-2 rounded-md bg-blue-700 px-4 py-3 font-semibold text-white transition hover:bg-blue-800 focus:outline-none focus:ring-4 focus:ring-blue-200"
                    >
                      <Send size={18} aria-hidden="true" />
                      Submit
                    </button>
                  ) : (
                    <button
                      onClick={() => goToQuestion(Math.min(currentIndex + 1, questionBank.length - 1))}
                      className="flex items-center justify-center gap-2 rounded-md bg-blue-700 px-4 py-3 font-semibold text-white transition hover:bg-blue-800 focus:outline-none focus:ring-4 focus:ring-blue-200"
                    >
                      Berikutnya
                      <ArrowRight size={18} aria-hidden="true" />
                    </button>
                  )}
                </div>
              </div>
            </section>
          </main>
        </div>

        {showMobilePanel ? (
          <div className="fixed inset-0 z-40 bg-slate-950/40 lg:hidden" role="dialog" aria-modal="true">
            <div className="h-full w-[86vw] max-w-sm bg-white shadow-soft">
              <div className="flex items-center justify-between border-b border-slate-200 p-4">
                <p className="font-bold text-slate-950">Daftar Soal</p>
                <button
                  onClick={() => setShowMobilePanel(false)}
                  className="flex h-9 w-9 items-center justify-center rounded-md border border-slate-300 text-slate-700"
                  aria-label="Tutup daftar soal"
                >
                  <X size={18} aria-hidden="true" />
                </button>
              </div>
              <QuestionPanel
                answers={answers}
                currentIndex={currentIndex}
                doubtful={doubtful}
                goToQuestion={goToQuestion}
                isMobile
                questions={questionBank}
              />
            </div>
          </div>
        ) : null}

        {showSubmitConfirm ? (
          <ConfirmModal
            answeredCount={answeredCount}
            doubtfulCount={doubtfulCount}
            unansweredCount={summary.unanswered}
            onCancel={() => setShowSubmitConfirm(false)}
            onConfirm={finishExam}
          />
        ) : null}
      </div>
    </Shell>
  );
}

function AdminPage({
  adminAuth,
  adminExams,
  adminMessage,
  adminQuestions,
  adminSession,
  attempts,
  deleteAttempt,
  deleteExam,
  deleteQuestion,
  isAdmin,
  onBack,
  onLogin,
  onLogout,
  onSignup,
  newExam,
  questionForm,
  saveQuestion,
  saveSettings,
  selectedAdminExamId,
  selectedAttempt,
  selectAdminExam,
  setAdminAuth,
  setQuestionForm,
  setSelectedAttempt,
  setSettingsForm,
  settingsForm,
  uploadQuestionImage,
}) {
  if (!isSupabaseConfigured) {
    return (
      <Shell centered>
        <section className="w-full max-w-lg rounded-lg border border-slate-200 bg-white p-6 shadow-soft">
          <h1 className="text-2xl font-bold text-slate-950">Supabase belum aktif</h1>
          <p className="mt-2 text-sm leading-6 text-slate-600">Isi environment variable Supabase lalu jalankan ulang aplikasi.</p>
          <button onClick={onBack} className="mt-5 rounded-md border border-slate-300 px-4 py-3 font-semibold text-slate-800">Kembali</button>
        </section>
      </Shell>
    );
  }

  if (!adminSession) {
    return (
      <Shell centered>
        <section className="w-full max-w-md rounded-lg border border-slate-200 bg-white p-6 shadow-soft sm:p-8">
          <div className="mb-6">
            <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-md bg-blue-600 text-white">
              <Database size={25} aria-hidden="true" />
            </div>
            <p className="text-sm font-semibold uppercase tracking-[0.18em] text-blue-700">Admin</p>
            <h1 className="mt-2 text-2xl font-bold text-slate-950">Login Admin</h1>
          </div>
          <form className="space-y-4" onSubmit={onLogin}>
            <label className="block">
              <span className="text-sm font-semibold text-slate-700">Email admin</span>
              <input
                required
                type="email"
                value={adminAuth.email}
                onChange={(event) => setAdminAuth((value) => ({ ...value, email: event.target.value }))}
                className="mt-2 w-full rounded-md border border-slate-300 px-4 py-3 outline-none focus:border-blue-600 focus:ring-4 focus:ring-blue-100"
              />
            </label>
            <label className="block">
              <span className="text-sm font-semibold text-slate-700">Password</span>
              <input
                required
                type="password"
                value={adminAuth.password}
                onChange={(event) => setAdminAuth((value) => ({ ...value, password: event.target.value }))}
                className="mt-2 w-full rounded-md border border-slate-300 px-4 py-3 outline-none focus:border-blue-600 focus:ring-4 focus:ring-blue-100"
              />
            </label>
            {adminMessage ? <p className="rounded-md bg-slate-50 p-3 text-sm text-slate-600">{adminMessage}</p> : null}
            <button className="flex w-full items-center justify-center gap-2 rounded-md bg-blue-700 px-4 py-3 font-semibold text-white">
              <LogIn size={18} aria-hidden="true" />
              Login
            </button>
            <button type="button" onClick={onSignup} className="flex w-full items-center justify-center gap-2 rounded-md border border-slate-300 px-4 py-3 font-semibold text-slate-800">
              Buat Akun Admin
            </button>
            <button type="button" onClick={onBack} className="flex w-full items-center justify-center gap-2 rounded-md border border-slate-300 px-4 py-3 font-semibold text-slate-800">
              <ArrowLeft size={18} aria-hidden="true" />
              Kembali ke Login Regu
            </button>
          </form>
        </section>
      </Shell>
    );
  }

  if (!isAdmin) {
    return (
      <Shell centered>
        <section className="w-full max-w-2xl rounded-lg border border-slate-200 bg-white p-6 shadow-soft">
          <h1 className="text-2xl font-bold text-slate-950">Akun belum menjadi admin</h1>
          <p className="mt-3 text-sm leading-6 text-slate-600">{adminMessage}</p>
          <p className="mt-3 rounded-md bg-blue-50 p-3 text-sm leading-6 text-blue-900">
            Buka Supabase Authentication &gt; Users, copy UID akun ini, lalu jalankan query insert ke tabel admin_profiles seperti contoh di `supabase/schema.sql`.
          </p>
          <button onClick={onLogout} className="mt-5 flex items-center gap-2 rounded-md bg-blue-700 px-4 py-3 font-semibold text-white">
            <LogOut size={18} aria-hidden="true" />
            Logout
          </button>
        </section>
      </Shell>
    );
  }

  return (
    <Shell>
      <main className="mx-auto min-h-screen w-full max-w-7xl px-4 py-6 sm:py-8">
        <section className="rounded-lg border border-slate-200 bg-white shadow-soft">
          <div className="flex flex-col gap-4 border-b border-slate-200 p-5 sm:flex-row sm:items-center sm:justify-between sm:p-6">
            <div>
              <p className="text-sm font-semibold text-blue-700">Admin</p>
              <h1 className="mt-2 text-2xl font-bold text-slate-950">Dashboard Bank Soal</h1>
              <p className="mt-1 text-sm text-slate-600">{adminExams.length} paket · {adminQuestions.length} soal paket terpilih · {attempts.length} nilai regu</p>
            </div>
            <div className="flex flex-col gap-2 sm:flex-row">
              <button onClick={onBack} className="flex items-center justify-center gap-2 rounded-md border border-slate-300 px-4 py-3 font-semibold text-slate-800">
                <ArrowLeft size={18} aria-hidden="true" />
                Ke Halaman Regu
              </button>
              <button onClick={onLogout} className="flex items-center justify-center gap-2 rounded-md bg-slate-900 px-4 py-3 font-semibold text-white">
                <LogOut size={18} aria-hidden="true" />
                Logout
              </button>
            </div>
          </div>

          {adminMessage ? <p className="m-5 rounded-md bg-blue-50 p-3 text-sm text-blue-900">{adminMessage}</p> : null}

          <div className="grid gap-0 lg:grid-cols-[420px_1fr]">
            <div className="border-b border-slate-200 p-5 lg:border-b-0 lg:border-r">
              <div className="rounded-lg border border-slate-200 bg-white p-4">
                <div className="flex items-center justify-between gap-3">
                  <h2 className="font-bold text-slate-950">Paket Soal</h2>
                  <button type="button" onClick={newExam} className="flex items-center gap-2 rounded-md border border-slate-300 px-3 py-2 text-sm font-semibold text-slate-800">
                    <Plus size={16} aria-hidden="true" />
                    Paket Baru
                  </button>
                </div>
                <div className="mt-4 space-y-2">
                  {adminExams.map((exam) => (
                    <button
                      key={exam.id}
                      type="button"
                      onClick={() => selectAdminExam(exam.id)}
                      className={`w-full rounded-md border p-3 text-left text-sm ${selectedAdminExamId === exam.id ? 'border-blue-500 bg-blue-50 text-blue-900' : 'border-slate-200 bg-white text-slate-700'}`}
                    >
                      <span className="font-bold">{exam.title}</span>
                      <span className="block text-xs text-slate-500">{exam.subject} · {exam.durationMinutes} menit · {exam.active ? 'Aktif' : 'Nonaktif'}</span>
                    </button>
                  ))}
                </div>
              </div>

              <form className="mt-5 rounded-lg border border-slate-200 bg-slate-50 p-4" onSubmit={saveSettings}>
                <div className="flex items-center justify-between gap-3">
                  <h2 className="font-bold text-slate-950">{settingsForm.id ? 'Edit Paket' : 'Tambah Paket'}</h2>
                  {settingsForm.id ? (
                    <button type="button" onClick={() => deleteExam(settingsForm.id)} className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-sm font-semibold text-red-700">
                      Hapus Permanen
                    </button>
                  ) : null}
                </div>
                <div className="mt-4 space-y-3">
                  <AdminInput label="Judul" value={settingsForm.title} onChange={(value) => setSettingsForm((form) => ({ ...form, title: value }))} />
                  <AdminInput label="Subjek" value={settingsForm.subject} onChange={(value) => setSettingsForm((form) => ({ ...form, subject: value }))} />
                  <AdminInput label="Durasi menit" type="number" value={settingsForm.duration_minutes} onChange={(value) => setSettingsForm((form) => ({ ...form, duration_minutes: value }))} />
                  <label className="flex items-center gap-2 text-sm font-semibold text-slate-700">
                    <input
                      type="checkbox"
                      checked={settingsForm.active}
                      onChange={(event) => setSettingsForm((form) => ({ ...form, active: event.target.checked }))}
                    />
                    Paket aktif untuk regu
                  </label>
                  <button className="flex w-full items-center justify-center gap-2 rounded-md bg-blue-700 px-4 py-3 font-semibold text-white">
                    <Save size={18} aria-hidden="true" />
                    Simpan Paket
                  </button>
                </div>
              </form>

              <form className="mt-5 rounded-lg border border-slate-200 bg-white p-4" onSubmit={saveQuestion}>
                <div className="flex items-center justify-between gap-3">
                  <h2 className="font-bold text-slate-950">{questionForm.id ? 'Edit Soal' : 'Tambah Soal'}</h2>
                  <button
                    type="button"
                    onClick={() => setQuestionForm({ ...emptyQuestionForm, exam_id: selectedAdminExamId, sort_order: adminQuestions.length + 1 })}
                    className="flex items-center gap-2 rounded-md border border-slate-300 px-3 py-2 text-sm font-semibold text-slate-800"
                  >
                    <Plus size={16} aria-hidden="true" />
                    Baru
                  </button>
                </div>
                <div className="mt-4 space-y-3">
                  <label className="block">
                    <span className="text-sm font-semibold text-slate-700">Paket soal</span>
                    <select
                      value={questionForm.exam_id || selectedAdminExamId}
                      onChange={(event) => setQuestionForm((form) => ({ ...form, exam_id: event.target.value }))}
                      className="mt-2 w-full rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-blue-600 focus:ring-4 focus:ring-blue-100"
                    >
                      <option value="">Pilih paket</option>
                      {adminExams.map((exam) => (
                        <option key={exam.id} value={exam.id}>
                          {exam.title}
                        </option>
                      ))}
                    </select>
                  </label>
                  <AdminInput label="Nomor urut" type="number" value={questionForm.sort_order} onChange={(value) => setQuestionForm((form) => ({ ...form, sort_order: value }))} />
                  <label className="block">
                    <span className="text-sm font-semibold text-slate-700">Teks soal</span>
                    <textarea
                      required
                      value={questionForm.text}
                      onChange={(event) => setQuestionForm((form) => ({ ...form, text: event.target.value }))}
                      className="mt-2 min-h-24 w-full rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-blue-600 focus:ring-4 focus:ring-blue-100"
                    />
                  </label>
                  <AdminInput label="URL gambar" value={questionForm.image} onChange={(value) => setQuestionForm((form) => ({ ...form, image: value }))} placeholder="Upload gambar atau isi URL" />
                  <label className="block">
                    <span className="text-sm font-semibold text-slate-700">Upload gambar dari file explorer</span>
                    <div className="mt-2 flex items-center gap-2 rounded-md border border-dashed border-slate-300 bg-slate-50 p-3">
                      <Upload size={18} className="text-slate-500" aria-hidden="true" />
                      <input
                        type="file"
                        accept="image/*"
                        onChange={(event) => uploadQuestionImage(event.target.files?.[0])}
                        className="w-full text-sm text-slate-700"
                      />
                    </div>
                  </label>
                  {['A', 'B', 'C', 'D', 'E'].map((key) => (
                    <AdminInput
                      key={key}
                      label={`Opsi ${key}`}
                      value={questionForm.options[key]}
                      onChange={(value) => setQuestionForm((form) => ({ ...form, options: { ...form.options, [key]: value } }))}
                    />
                  ))}
                  <label className="block">
                    <span className="text-sm font-semibold text-slate-700">Jawaban benar</span>
                    <select
                      value={questionForm.answer}
                      onChange={(event) => setQuestionForm((form) => ({ ...form, answer: event.target.value }))}
                      className="mt-2 w-full rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-blue-600 focus:ring-4 focus:ring-blue-100"
                    >
                      {['A', 'B', 'C', 'D', 'E'].map((key) => (
                        <option key={key} value={key}>{key}</option>
                      ))}
                    </select>
                  </label>
                  <label className="flex items-center gap-2 text-sm font-semibold text-slate-700">
                    <input
                      type="checkbox"
                      checked={questionForm.active}
                      onChange={(event) => setQuestionForm((form) => ({ ...form, active: event.target.checked }))}
                    />
                    Soal aktif
                  </label>
                  <button className="flex w-full items-center justify-center gap-2 rounded-md bg-blue-700 px-4 py-3 font-semibold text-white">
                    <Save size={18} aria-hidden="true" />
                    Simpan Soal
                  </button>
                </div>
              </form>
            </div>

            <div className="min-w-0">
              <div className="grid border-b border-slate-200 lg:grid-cols-2">
                <section className="border-b border-slate-200 p-5 lg:border-b-0 lg:border-r">
                  <h2 className="font-bold text-slate-950">Daftar Soal</h2>
                  <div className="mt-4 max-h-[520px] space-y-3 overflow-auto pr-1 scrollbar-thin">
                    {adminQuestions.map((question) => (
                      <div key={question.id} className="rounded-lg border border-slate-200 p-3">
                        <div className="flex items-start justify-between gap-3">
                          <div className="min-w-0">
                            <p className="text-sm font-bold text-slate-950">#{question.sort_order} {question.text}</p>
                            <p className="mt-1 text-xs text-slate-500">Kunci: {question.answer} · {question.active ? 'Aktif' : 'Nonaktif'}</p>
                          </div>
                          <div className="flex gap-2">
                            <button onClick={() => setQuestionForm(questionToForm(question))} className="rounded-md border border-slate-300 p-2 text-slate-700" aria-label="Edit soal">
                              <Pencil size={16} aria-hidden="true" />
                            </button>
                            <button onClick={() => deleteQuestion(question.id)} className="rounded-md border border-red-200 bg-red-50 p-2 text-red-700" aria-label="Hapus soal">
                              <Trash2 size={16} aria-hidden="true" />
                            </button>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </section>

                <section className="p-5">
                  <h2 className="font-bold text-slate-950">Nilai Regu</h2>
                  <div className="mt-4 max-h-[520px] space-y-3 overflow-auto pr-1 scrollbar-thin">
                    {attempts.length === 0 ? <p className="text-sm text-slate-600">Belum ada nilai yang masuk.</p> : null}
                    {attempts.map((attempt) => (
                      <button
                        key={attempt.id}
                        onClick={() => setSelectedAttempt(attempt)}
                        className={`w-full rounded-lg border p-3 text-left ${selectedAttempt?.id === attempt.id ? 'border-blue-500 bg-blue-50' : 'border-slate-200 bg-white'}`}
                      >
                        <div className="flex justify-between gap-3">
                          <div className="min-w-0">
                            <p className="truncate font-bold text-slate-950">{attempt.team_name}</p>
                            <p className="mt-1 text-xs text-slate-500">No. {attempt.team_number} · {formatDateTime(attempt.finished_at)}</p>
                          </div>
                          <span className="rounded-md bg-blue-700 px-3 py-1 text-sm font-bold text-white">{attempt.score}</span>
                        </div>
                      </button>
                    ))}
                  </div>
                </section>
              </div>

              {selectedAttempt ? (
                <section className="p-5">
                  <div className="mb-4 flex items-center justify-between gap-3">
                    <h2 className="font-bold text-slate-950">Detail Nilai</h2>
                    <button onClick={() => deleteAttempt(selectedAttempt.id)} className="flex items-center gap-2 rounded-md border border-red-200 bg-red-50 px-3 py-2 text-sm font-semibold text-red-700">
                      <Trash2 size={16} aria-hidden="true" />
                      Hapus Nilai
                    </button>
                  </div>
                  <HistoryDetail attempt={selectedAttempt} />
                </section>
              ) : null}
            </div>
          </div>
        </section>
      </main>
    </Shell>
  );
}

function AdminInput({ label, onChange, placeholder = '', type = 'text', value }) {
  return (
    <label className="block">
      <span className="text-sm font-semibold text-slate-700">{label}</span>
      <input
        type={type}
        value={value}
        onChange={(event) => onChange(event.target.value)}
        placeholder={placeholder}
        className="mt-2 w-full rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-blue-600 focus:ring-4 focus:ring-blue-100"
      />
    </label>
  );
}

function ReviewPage({ answers, attempt, backLabel, onBack, onRestart, questionSource, result, subtitle, title }) {
  return (
    <Shell>
      <main className="mx-auto min-h-screen w-full max-w-6xl px-4 py-6 sm:py-8">
        <section className="rounded-lg border border-slate-200 bg-white shadow-soft">
          <div className="flex flex-col gap-4 border-b border-slate-200 p-5 sm:flex-row sm:items-center sm:justify-between sm:p-6">
            <div>
              <p className="text-sm font-semibold text-blue-700">Koreksi Jawaban</p>
              <h1 className="mt-2 text-2xl font-bold text-slate-950">{title}</h1>
              <p className="mt-1 text-sm text-slate-600">{subtitle}</p>
            </div>
            <div className="flex flex-col gap-2 sm:flex-row">
              <button onClick={onBack} className="flex items-center justify-center gap-2 rounded-md border border-slate-300 bg-white px-4 py-3 font-semibold text-slate-800">
                <ArrowLeft size={18} aria-hidden="true" />
                {backLabel}
              </button>
              {onRestart ? (
                <button onClick={onRestart} className="flex items-center justify-center gap-2 rounded-md bg-blue-700 px-4 py-3 font-semibold text-white">
                  <RotateCcw size={18} aria-hidden="true" />
                  Ulangi
                </button>
              ) : null}
            </div>
          </div>
          <div className="grid gap-3 border-b border-slate-200 bg-slate-50 p-4 sm:grid-cols-3 sm:p-6">
            <ReviewLegend tone="green" label="Benar" value={result.correct} />
            <ReviewLegend tone="red" label="Salah" value={result.wrong} />
            <ReviewLegend tone="slate" label="Tidak dijawab" value={result.unanswered} />
          </div>
          <QuestionReviewList answers={answers} questionSource={questionSource} />
        </section>
      </main>
    </Shell>
  );
}

function QuestionReviewList({ answers, questionSource }) {
  return (
    <div className="space-y-4 p-4 sm:p-6">
      {questionSource.map((question, index) => {
        const chosen = answers[question.id];
        const isCorrect = chosen === question.answer;
        const isUnanswered = !chosen;
        const statusLabel = isUnanswered ? 'Tidak dijawab' : isCorrect ? 'Benar' : 'Salah';
        const statusClass = isUnanswered
          ? 'border-slate-200 bg-slate-100 text-slate-700'
          : isCorrect
            ? 'border-green-200 bg-green-50 text-green-800'
            : 'border-red-200 bg-red-50 text-red-800';

        return (
          <article key={question.id} className="rounded-lg border border-slate-200 bg-white p-4 sm:p-5">
            <div className="flex flex-wrap items-center gap-2">
              <span className="rounded-md bg-slate-900 px-2.5 py-1 text-sm font-bold text-white">Soal {index + 1}</span>
              <span className={`rounded-md border px-2.5 py-1 text-sm font-bold ${statusClass}`}>{statusLabel}</span>
            </div>
            <h2 className="mt-3 text-base font-bold leading-7 text-slate-950">{question.text}</h2>
            {question.image ? (
              <img src={question.image} alt={`Gambar soal ${index + 1}`} className="mt-4 max-h-64 w-full rounded-md border border-slate-200 object-contain" />
            ) : null}
            <div className="mt-4 grid gap-3 lg:grid-cols-2">
              {Object.entries(question.options).map(([key, value]) => {
                const selected = chosen === key;
                const correct = question.answer === key;
                const optionClass = correct
                  ? 'border-green-300 bg-green-50 text-green-900'
                  : selected
                    ? 'border-red-300 bg-red-50 text-red-900'
                    : 'border-slate-200 bg-white text-slate-700';
                return (
                  <div key={key} className={`flex items-start gap-3 rounded-md border p-3 ${optionClass}`}>
                    <span className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-md text-sm font-bold ${correct ? 'bg-green-700 text-white' : selected ? 'bg-red-700 text-white' : 'bg-slate-100 text-slate-700'}`}>
                      {key}
                    </span>
                    <div>
                      <p className="text-sm leading-6">{value}</p>
                      {correct ? <p className="mt-1 text-xs font-bold text-green-700">Jawaban benar</p> : null}
                      {selected && !correct ? <p className="mt-1 text-xs font-bold text-red-700">Jawaban regu</p> : null}
                    </div>
                  </div>
                );
              })}
            </div>
            <div className="mt-4 rounded-md bg-slate-50 p-3 text-sm leading-6 text-slate-700">
              <p>
                Jawaban regu: <span className="font-bold text-slate-950">{chosen ? `${chosen}. ${question.options[chosen]}` : 'Tidak dijawab'}</span>
              </p>
              {!isCorrect ? (
                <p>
                  Jawaban benar: <span className="font-bold text-green-700">{question.answer}. {question.options[question.answer]}</span>
                </p>
              ) : null}
            </div>
          </article>
        );
      })}
    </div>
  );
}

function HistoryDetail({ attempt }) {
  const questionSource = (attempt.question_snapshot || []).map(normalizeQuestion);
  const answers = attempt.answers || {};
  const result = {
    score: attempt.score,
    correct: attempt.correct_count,
    wrong: attempt.wrong_count,
    unanswered: attempt.unanswered_count,
    total: attempt.total_questions,
  };

  return (
    <div className="rounded-lg border border-slate-200">
      <div className="rounded-t-lg bg-slate-50 p-4">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
          <div>
            <p className="text-sm font-semibold text-blue-700">Detail Regu</p>
            <h2 className="mt-1 text-xl font-bold text-slate-950">{attempt.team_name}</h2>
            <p className="mt-1 text-sm text-slate-600">Nomor regu: {attempt.team_number}</p>
            <p className="mt-1 text-sm text-slate-600">Submit: {formatDateTime(attempt.finished_at)}</p>
          </div>
          <div className="rounded-lg bg-blue-700 px-5 py-3 text-center text-white">
            <p className="text-xs font-semibold text-blue-100">Skor</p>
            <p className="text-3xl font-bold">{attempt.score}</p>
          </div>
        </div>
        <div className="mt-4 grid gap-2 sm:grid-cols-4">
          <ResultCard label="Benar" value={attempt.correct_count} tone="green" />
          <ResultCard label="Salah" value={attempt.wrong_count} tone="red" />
          <ResultCard label="Tidak Dijawab" value={attempt.unanswered_count} tone="slate" />
          <ResultCard label="Total Soal" value={attempt.total_questions} tone="blue" />
        </div>
      </div>
      <QuestionReviewList answers={answers} questionSource={questionSource} />
    </div>
  );
}

function Shell({ centered = false, children }) {
  return (
    <div className={centered ? 'flex min-h-screen items-center justify-center bg-slate-100 p-4' : 'min-h-screen bg-slate-100'}>
      {children}
      <Watermark />
    </div>
  );
}

function Watermark() {
  return (
    <a
      href="https://www.instagram.com/imaddd24_/"
      target="_blank"
      rel="noreferrer"
      className="fixed bottom-3 right-3 z-[60] rounded-md border border-slate-200 bg-white/90 px-3 py-1.5 text-xs font-semibold text-slate-500 shadow-sm backdrop-blur transition hover:border-blue-200 hover:text-blue-700 focus:outline-none focus:ring-4 focus:ring-blue-100"
      aria-label="Buka Instagram MadeSurya24"
    >
      Web by MadeSurya24
    </a>
  );
}

function Info({ label, value }) {
  return (
    <div className="rounded-md border border-slate-200 bg-slate-50 p-3">
      <p className="text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">{label}</p>
      <p className="mt-1 truncate font-semibold text-slate-900">{value}</p>
    </div>
  );
}

function QuestionPanel({ answers, currentIndex, doubtful, goToQuestion, isMobile, questions }) {
  return (
    <aside className={`${isMobile ? 'h-[calc(100%-65px)]' : 'hidden border-r border-slate-200 bg-white lg:block'} overflow-y-auto scrollbar-thin`}>
      <div className="p-4 lg:sticky lg:top-16">
        {!isMobile ? (
          <div className="mb-5">
            <p className="text-sm font-semibold text-slate-500">Navigasi Soal</p>
            <h2 className="text-lg font-bold text-slate-950">Daftar Nomor</h2>
          </div>
        ) : null}

        <div className="grid grid-cols-5 gap-2 sm:grid-cols-6 lg:grid-cols-5">
          {questions.map((question, index) => {
            const isActive = index === currentIndex;
            const isAnswered = Boolean(answers[question.id]);
            const isDoubtful = Boolean(doubtful[question.id]);
            const statusClass = isDoubtful
              ? 'border-yellow-300 bg-yellow-100 text-yellow-900'
              : isAnswered
                ? 'border-blue-600 bg-blue-700 text-white'
                : 'border-slate-300 bg-white text-slate-700';

            return (
              <button
                key={question.id}
                onClick={() => goToQuestion(index)}
                className={`aspect-square rounded-md border text-sm font-bold transition hover:scale-[1.02] focus:outline-none focus:ring-4 focus:ring-blue-100 ${statusClass} ${isActive ? 'ring-2 ring-blue-300 ring-offset-2' : ''}`}
                aria-label={`Soal ${index + 1}`}
              >
                {index + 1}
              </button>
            );
          })}
        </div>

        <div className="mt-6 space-y-2 text-sm text-slate-600">
          <Legend color="bg-white border-slate-300" label="Belum dijawab" />
          <Legend color="bg-blue-700 border-blue-700" label="Sudah dijawab" />
          <Legend color="bg-yellow-100 border-yellow-300" label="Ragu-ragu" />
        </div>
      </div>
    </aside>
  );
}

function Legend({ color, label }) {
  return (
    <div className="flex items-center gap-2">
      <span className={`h-4 w-4 rounded border ${color}`} aria-hidden="true" />
      <span>{label}</span>
    </div>
  );
}

function StatusPill({ answered, doubtful }) {
  if (doubtful) {
    return (
      <span className="inline-flex w-max items-center gap-2 rounded-md bg-yellow-100 px-3 py-2 text-sm font-semibold text-yellow-900">
        <Flag size={16} aria-hidden="true" />
        Ragu-ragu
      </span>
    );
  }
  if (answered) {
    return (
      <span className="inline-flex w-max items-center gap-2 rounded-md bg-blue-50 px-3 py-2 text-sm font-semibold text-blue-800">
        <CheckCircle2 size={16} aria-hidden="true" />
        Sudah dijawab
      </span>
    );
  }
  return (
    <span className="inline-flex w-max items-center gap-2 rounded-md bg-slate-100 px-3 py-2 text-sm font-semibold text-slate-700">
      <AlertCircle size={16} aria-hidden="true" />
      Belum dijawab
    </span>
  );
}

function ConfirmModal({ answeredCount, doubtfulCount, unansweredCount, onCancel, onConfirm }) {
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/50 p-4" role="dialog" aria-modal="true">
      <section className="w-full max-w-md rounded-lg bg-white p-6 shadow-soft">
        <div className="flex h-12 w-12 items-center justify-center rounded-md bg-blue-50 text-blue-700">
          <Send size={24} aria-hidden="true" />
        </div>
        <h2 className="mt-5 text-xl font-bold text-slate-950">Submit jawaban?</h2>
        <p className="mt-2 text-sm leading-6 text-slate-600">
          Pastikan semua jawaban sudah diperiksa. Setelah submit, hasil ujian akan langsung ditampilkan dan disimpan.
        </p>
        <div className="mt-5 grid grid-cols-3 gap-2 text-center text-sm">
          <MiniStat label="Dijawab" value={answeredCount} />
          <MiniStat label="Ragu" value={doubtfulCount} />
          <MiniStat label="Kosong" value={unansweredCount} />
        </div>
        <div className="mt-6 grid grid-cols-2 gap-3">
          <button onClick={onCancel} className="rounded-md border border-slate-300 bg-white px-4 py-3 font-semibold text-slate-800 transition hover:bg-slate-50">
            Cek Lagi
          </button>
          <button onClick={onConfirm} className="rounded-md bg-blue-700 px-4 py-3 font-semibold text-white transition hover:bg-blue-800 focus:outline-none focus:ring-4 focus:ring-blue-200">
            Ya, Submit
          </button>
        </div>
      </section>
    </div>
  );
}

function MiniStat({ label, value }) {
  return (
    <div className="rounded-md bg-slate-100 p-3">
      <p className="font-bold text-slate-950">{value}</p>
      <p className="mt-1 text-xs text-slate-600">{label}</p>
    </div>
  );
}

function ReviewLegend({ label, value, tone }) {
  const toneClass = {
    green: 'border-green-200 bg-green-50 text-green-800',
    red: 'border-red-200 bg-red-50 text-red-800',
    slate: 'border-slate-200 bg-white text-slate-800',
  }[tone];

  return (
    <div className={`rounded-lg border p-4 ${toneClass}`}>
      <p className="text-sm font-semibold">{label}</p>
      <p className="mt-1 text-2xl font-bold">{value}</p>
    </div>
  );
}

function ResultCard({ label, value, tone }) {
  const toneClass = {
    green: 'border-green-200 bg-green-50 text-green-800',
    red: 'border-red-200 bg-red-50 text-red-800',
    slate: 'border-slate-200 bg-slate-50 text-slate-800',
    blue: 'border-blue-200 bg-blue-50 text-blue-800',
  }[tone];

  return (
    <div className={`rounded-lg border p-4 ${toneClass}`}>
      <p className="text-sm font-semibold">{label}</p>
      <p className="mt-2 text-3xl font-bold">{value}</p>
    </div>
  );
}

export default App;
